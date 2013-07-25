# require 'rubygems'
require 'minitest/autorun'
require 'ostruct'
require_relative '../lib/acts_as_associate_tree'

# testing data
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


class Object # :nodoc:
  ##
  # Add a temporary stubbed method replacing +name+ for the duration
  # of the +block+. If +val_or_callable+ responds to #call, then it
  # returns the result of calling it, otherwise returns the value
  # as-is. Cleans up the stub at the end of the +block+.
  #
  #     def test_stale_eh
  #       obj_under_test = Something.new
  #       refute obj_under_test.stale?
  #
  #       Time.stub :now, Time.at(0) do
  #         assert obj_under_test.stale?
  #       end
  #     end
  def stub name, val_or_callable, &block
    new_name = "__minitest_stub__#{name}"

    metaclass = class << self; self; end
    metaclass.send :alias_method, new_name, name
    metaclass.send :define_method, name do |*args|
      if val_or_callable.respond_to? :call then
        val_or_callable.call(*args)
      else
        val_or_callable
      end
    end

    yield self
  ensure
    metaclass.send :undef_method, name
    metaclass.send :alias_method, name, new_name
    metaclass.send :undef_method, new_name
  end
end
