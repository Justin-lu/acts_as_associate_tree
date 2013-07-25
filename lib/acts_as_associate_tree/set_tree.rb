module ActsAsAssociateTree
  class SetTree
    attr_reader :root
    def initialize
      @node_sets = []
      @expanding_symbol = :all
    end
  
    ##
    # 添加根节点，如果不需要根节点，可以不添加，节点类型需为一个哈希
    def enroot(root)
      raise ConfigurationError.new("Root configuration should be a HASH INSTANCE") unless root.kind_of?(Hash)
      @root = root
    end
  
    # expanding_symbol = :all || :set_symbol
    def expanding_symbol(type = nil)
      return @expanding_symbol if type.nil?
      raise ConfigurationError.new('expanding_symbol Must be a SYMBOL') unless type.kind_of? Symbol
      @expanding_symbol = type
    end

    ##
    # 添加一个新的节点集
    def add_set(&set_block)
      @node_sets << NodeSet.new(self, &set_block)
      self
    end

    ##
    # 展开所有的节点集
    def expand
      # Expand all node sets
      expanded_node_sets = []
      @node_sets.each do |node_set|
        expanded_node_sets += node_set.expand
      end
      # set up root attributes
      unless @root.nil?
        @root[:children] = expanded_node_sets
        expanded_node_sets = @root
      end

      expanded_node_sets
    end
  end
end