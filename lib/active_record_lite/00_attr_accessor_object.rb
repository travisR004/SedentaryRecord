class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        sym_name = "@#{name}".to_sym
        self.instance_variable_get(sym_name)
      end

      p name

      define_method("#{name}=") do |val|
        sym_name ="@#{name}".to_sym
        self.instance_variable_set(sym_name, val)
      end
    end
  end
end
