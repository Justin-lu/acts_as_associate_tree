require_relative 'helper'

class TestNodeSetWithoutSymbol < MiniTest::Unit::TestCase
  include ActsAsAssociateTree
  def setup
    @node_set = NodeSet.new(OpenStruct.new(:expanded_type => :all))  do
      nodes { Foo.all }
      node_attrs { { :text => i } }
      children {
        nodes { items }
        node_attrs { { :text => i } }
      }
    end
  end
  
  def test_should_raise_exception_when_node_attrs_is_not_hash
    @node_set.node_attrs { ["not a Hash"] }
    assert_raises(ActsAsAssociateTree::ConfigurationError) { @node_set.expand }
  end
  
  def test_expand_node_set_without_setting_up_set_attributes
    assert_equal [{:text=>1, :children=>[{:text=>"Item0", :leaf=>true}]}, {:text=>2, :children=>[{:text=>"Item0", :leaf=>true}, {:text=>"Item1", :leaf=>true}]}], @node_set.expand
  end
  
  def test_expand_node_set_and_set_up_set_attributes
    @node_set.set_attrs { { :text => 'Foo' } }
    assert_equal [{:text=>"Foo", :children=>[{:text=>1, :children=>[{:text=>"Item0", :leaf=>true}]}, {:text=>2, :children=>[{:text=>"Item0", :leaf=>true}, {:text=>"Item1", :leaf=>true}]}]}], @node_set.expand
  end
end

# 
# puts ActsAsAssociateTree.generate_tree_nodes {
#   # enroot :text => "Root"
#   add_set {
#     set_attrs { { :text => 'Foo' } }
#     nodes { Foo.all }
#     node_attrs { { :text => i } }
#     child {
#       # set_attrs { "Foo Items" }
#       nodes { items }
#       node_attrs { { :text => i } }
#     }
#   }
#   add_set {
#     set_attrs { { :text => 'Foo' } }
#     nodes { Foo.all }
#     node_attrs { { :text => i } }
#     child {
#       # set_attrs { "Foo Items" }
#       nodes { items }
#       node_attrs { { :text => i } }
#     }
#   }
#   expand_sets
# }

# generate_tree_nodes {
#   top_set {
#     nodes { unapproved_orders.where("number like %?%", params[:something]) }
#     node_attrs { { :id => id, :text => number, :check => true } }
#     child {
#       nodes { unapproved_orders.where("number like %?%", params[:something]) }
#       node_attrs { { :id => id, :text => number, :check => true } }
#     }
#     child {
#       nodes { unapproved_orders.where("number like %?%", params[:something]) }
#       node_attrs { { :id => id, :text => number, :check => true } }
#     }
#   }
# }
