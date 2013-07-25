require_relative 'helper'

class TestNodeSetWithSymbol < MiniTest::Unit::TestCase
  include ActsAsAssociateTree
  def setup
    node_set_proc = Proc.new do
      symbol :foo
      nodes { Foo.all }
      node_attrs { { :text => i } }
      children {
        symbol :foo_item
        nodes { items }
        node_attrs { { :text => i } }
      }
      children {
        symbol :another_foo_item
        nodes { items }
        node_attrs { { :text => i } }
      }
    end

    @node_set_with_foo_item_symbol = NodeSet.new(OpenStruct.new(:expanding_symbol => :foo_item), &node_set_proc)
    @node_set_with_all_symbol = NodeSet.new(OpenStruct.new(:expanding_symbol => :all), &node_set_proc)
  end

  def test_expand_node_set_under_symbol_restriction
    assert_equal value_of_node_set_with_foo_item_symbol, @node_set_with_foo_item_symbol.expand
  end

  def test_allow_symbol_specification_with_all_expanded_type
    @node_set_with_all_symbol.stub :mother_tree, OpenStruct.new(:expanded_type => :all) do
      refute_equal value_of_node_set_with_foo_item_symbol, @node_set_with_all_symbol.expand
      assert_equal value_of_node_set_with_all_symbol, @node_set_with_all_symbol.expand
    end
  end

  private
    def value_of_node_set_with_foo_item_symbol
      [{:text=>1, :children=>[{:text=>"Item0", :leaf=>true}]}, {:text=>2, :children=>[{:text=>"Item0", :leaf=>true}, {:text=>"Item1", :leaf=>true}]}]
    end

    def value_of_node_set_with_all_symbol
      [{:text=>1, :children=>[{:text=>"Item0", :leaf=>true}, {:text=>"Item0", :leaf=>true}]}, {:text=>2, :children=>[{:text=>"Item0", :leaf=>true}, {:text=>"Item1", :leaf=>true}, {:text=>"Item0", :leaf=>true}, {:text=>"Item1", :leaf=>true}]}]
    end
end