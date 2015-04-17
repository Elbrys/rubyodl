# borrowing from rails implementation 
# https://github.com/rails/rails/blob/c0357d789b4323da64f1f9f82fa720ec9bac17cf/activesupport/lib/active_support/core_ext/hash/compact.rb#L8
class Hash
  def compact
    self.select { |_, value| value.is_a?(Hash) ? value.compact.empty? : !value.nil?}
  end
end