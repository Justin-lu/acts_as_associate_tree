module ActsAsAssociateTree
  class NodeSet
    attr_reader :children_sets, :nodes_block, :node_attrs_block, :set_block, :set_attrs_block
    attr_reader :set_symbol, :expandable, :mother_tree, :parent_set  # for 'symbol' feature
    def initialize(mother_tree, parent_set = nil, &block)
      @children_sets = []
      @set_symbol = ''
      @mother_tree = mother_tree
      @expandable = true
      @parent_set = parent_set
      
      self.instance_eval &block
    end
    
    # with symbol setting, you would be able to generate only a part of a tree instead of a whole one
    def symbol(sym)
      raise ConfigurationError.new('symbol Must be a SYMBOL') unless sym.kind_of? Symbol
      @set_symbol = sym
      return if mother_tree.expanding_symbol == :all
      @expandable = false
      enable_expanding if mother_tree.expanding_symbol == @set_symbol
    end
    
    # resymbolize
    # def resymbol
    #   symbol set_symbol
    # end
    
    def enable_expanding
      @expandable = true
      parent_set.enable_expanding unless parent_set.nil?
    end

    ##
    # 树集的属性
    # block 的执行结果需返回一个 hash
    def set_attrs(&block)
      @set_attrs_block = block
    end
    
    ##
    # 节点集合
    def nodes(&block)
      @nodes_block = block
    end

    ##
    # 节点属性
    # block 的执行结果需返回一个 hash
    def node_attrs(&block)
      @node_attrs_block = block
    end

    ##
    # 子节点属性
    def children(&block)
      @children_sets << NodeSet.new(mother_tree, self, &block)
    end
    
    def expandable?
      expandable
    end
    
    ##
    # 展开树集
    def expand(parent_scope = Object)
      return [] unless expandable?
      nodes = parent_scope.instance_eval &nodes_block
      # Expand child set of each node
      expanded_set = nodes.map do |node|
        node_attrs = generate_node_attrs(node)
        expand_node_children_set(node, node_attrs)
      end
      # Wrap a set around the expaned set
      expanded_set = set_up_set_attributes(parent_scope, expanded_set) unless set_attrs_block.nil?

      expanded_set
    end

    private
      def generate_node_attrs(node)
        attrs = node.instance_eval &node_attrs_block
        raise ConfigurationError.new("Node attributes isn't a HASH INSTANCE") unless attrs.kind_of?(Hash)
        attrs
      end

      def expand_node_children_set(node, node_attrs)
        node_attrs[:children] = []
        children_sets.each do |children_set|
          node_attrs[:children] += children_set.expand(node)
        end
        if node_attrs[:children].empty?
          node_attrs.delete(:children)
          node_attrs[:leaf] = true
        end

        node_attrs
      end

      def set_up_set_attributes(parent_scope, expanded_set)
        set_attrs = parent_scope.instance_eval &set_attrs_block
        raise ConfigurationError.new("Set attributes isn't a HASH INSTANCE") unless set_attrs.kind_of?(Hash)
        set_attrs[:children] = expanded_set
        [set_attrs]
      end
  end
end
