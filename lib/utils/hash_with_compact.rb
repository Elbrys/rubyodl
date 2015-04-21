# borrowing from rails implementation 
# https://github.com/rails/rails/blob/c0357d789b4323da64f1f9f82fa720ec9bac17cf/activesupport/lib/active_support/core_ext/hash/compact.rb#L8
class Hash
  def compact
    self.select { |_, value| value.is_a?(Hash) ? !value.compact_and_check_if_empty : !value.nil? }
  end
  
  def compact!
    self.reject! {|_, value| value.is_a?(Hash) ? value.compact_and_check_if_empty : value.nil? }
  end
  
  def compact_and_check_if_empty
    self.compact!
    self.empty?
  end
end