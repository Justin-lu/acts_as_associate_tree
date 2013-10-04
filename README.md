支持你通过方法生成tree 数据
```ruby
     class Foo
       attr_reader :i
       def initialize(i)
         @i = i
       end

       def items
         foo_items = []
         i.times do |i|
           foo_items.push Foo.new("Item" + i.to_s)
         end
         foo_items
       end

       class << self
         def all
           all_foos = []
           2.times do |i|
             all_foos.push Foo.new(i + 1)
           end
           all_foos
         end
       end
     end
     
     generate_tree_nodes do
       nodes { Foo.all }
       node_attrs { { :text => i } } # invoke this block by the instance_eval
                                     # method of each element in nodes
       children {
         nodes { items }
         node_attrs { { :text => i } } # using nodes#element.instance_eval to run this block
       }
     end
```
通过`generate_tree_nodes`这个接口，可以生成以下数据

     [{
       :text=>1,
       :children=>[{
         :text=>"Item0",
         :leaf=>true
       }]
     }, {
       :text=>2,
       :children=>[{
         :text=>"Item0",
         :leaf=>true
       }, {
         :text=>"Item1",
         :leaf=>true
       }]
     }]

通过在application_controller或者model添加`include ActsAsAssociateTree`，然后就可以通过以下关系，快速构建你的tree了。
     class Parent < ActiveRecord::Base
        has_many :children
     end
     
     class Child < ActiveRecord::Base
       belongs_to :parent
     end
 
 其数据如下:
 
     # Parent.all
     # +-------+---------+
     # | id    | name    |
     # +-------+---------+
     # | 1     | xx1     |
     # | 2     | xx2     |
     # | 3     | xx3     |
     # | 4     | xx4     |
     # | 5     | xx5     |
     # +-------+---------+
     
     # Child.all
     # +-------+--------------+--------+
     # | id    | parent_id    | name   |
     # +-------+--------------+--------+
     # | 1     | 1            | xx0    |
     # | 2     | 1            | xx1    |
     # | 3     | 1            | xx2    |
     # | 4     | 2            | xx0    |
     # | 5     | 2            | xx1    |
     # +-------+--------------+--------+
 
 ```ruby
     class ParentController < ApplicationController
       include ActsAsAssociateTree
       
       # GET /parent/index_tree.json
       def index_tree
         special_tag = 'special_tag'
         render :josn => generate_tree_nodes {
           # 一个树可以有不同的结点集
           add_set {
             nodes { Parent.all }  # 结点的数据，block的执行结果需返回一个数组
             node_attrs { { :name => name } }  # 结点属性，block执行结果需返回一个Hash实例，block 中可以执行任何一个 Parent 实例能执行的方法
             children { 
               nodes { children }  # 在子结点中可以执行任何一个 Parent 实例能执行的方法
               node_attrs { { :name => name, :special => id == 1 ? special_tag : 'nothing' } }  # 每一个 block 中都能访问闭包变量，如 special_tag
             }
             # 可以添加多个子节点
             children {
               nodes { [1, 2, 3, 4, 5] }
               node_attrs { { :name => self } }
             }
           }
           # 其他结点集
           add_set {
             set_attrs { { :text => 'i am a tree nodes set' } }  # 可以添加结点集描述
             nodes { %w(act_as_associate_tree is so powerful) }
             node_attrs { { :text => self } }
           }
         }
       end
     end
 ```
 
 *index_tree* 方法会返回如下形式的数据
 
 ```javascript
     [{:name=>"xx1",
       :children=>
        [{:name=>"xx0", :special=>"special_tag", :leaf=>true},
         {:name=>"xx1", :special=>"nothing", :leaf=>true},
         {:name=>"xx2", :special=>"nothing", :leaf=>true},
         {:name=>1, :leaf=>true},
         {:name=>2, :leaf=>true},
         {:name=>3, :leaf=>true},
         {:name=>4, :leaf=>true},
         {:name=>5, :leaf=>true}]},
      {:name=>"xx2",
       :children=>
        [{:name=>"xx0", :special=>"nothing", :leaf=>true},
         {:name=>"xx1", :special=>"nothing", :leaf=>true},
         {:name=>1, :leaf=>true},
         {:name=>2, :leaf=>true},
         {:name=>3, :leaf=>true},
         {:name=>4, :leaf=>true},
         {:name=>5, :leaf=>true}]},
      {:name=>"xx3",
       :children=>
        [{:name=>1, :leaf=>true},
         {:name=>2, :leaf=>true},
         {:name=>3, :leaf=>true},
         {:name=>4, :leaf=>true},
         {:name=>5, :leaf=>true}]},
      {:name=>"xx4",
       :children=>
        [{:name=>1, :leaf=>true},
         {:name=>2, :leaf=>true},
         {:name=>3, :leaf=>true},
         {:name=>4, :leaf=>true},
         {:name=>5, :leaf=>true}]},
      {:name=>"xx5",
       :children=>
        [{:name=>1, :leaf=>true},
         {:name=>2, :leaf=>true},
         {:name=>3, :leaf=>true},
         {:name=>4, :leaf=>true},
         {:name=>5, :leaf=>true}]},
      {:text=>"i am a tree nodes set",
       :children=>
        [{:text=>"act_as_associate_tree", :leaf=>true},
         {:text=>"is", :leaf=>true},
         {:text=>"so", :leaf=>true},
         {:text=>"powerful", :leaf=>true}]}]
    ```
