class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      self.send(:define_method, name.to_sym) do
        instance_variable_get("@#{name}".to_sym)
      end



      self.send(:define_method, "#{name}=") do |object|
        instance_variable_set("@#{name}".to_sym, object)
      end
    end
  end
end
