# src/wpe_webkit/g_object.cr
module WPEWebKit
  class GObject < Wrapper
    def self.gtype_of(pointer : Void*) : C::GType
      pointer.as(C::GType**).value.value
    end

    def self.type_name(pointer : Void*) : String
      String.new(C.g_type_name(gtype_of(pointer)))
    end

    def self.construct(type : C::GType, properties : Hash(String, Wrapper?)) : Void*
      present = properties.compact
      names = present.keys.map(&.to_unsafe)
      values = present.values.map do |object|
        value = C::Value.new
        C.g_value_init(pointerof(value), gtype_of(object.to_unsafe))
        C.g_value_set_object(pointerof(value), object.to_unsafe)
        value
      end
      pointer = C.g_object_new_with_properties(type, names.size.to_u32, names.to_unsafe, values.to_unsafe)
      values.size.times { |index| C.g_value_unset(values.to_unsafe + index) }
      pointer
    end

    def self.read_property(pointer : Void*, name : String, type : Bool.class) : Bool
      value = 0
      C.g_object_get(pointer, name, pointerof(value), Pointer(Void).null)
      value != 0
    end

    def self.read_property(pointer : Void*, name : String, type : String.class) : String?
      value = Pointer(UInt8).null
      C.g_object_get(pointer, name, pointerof(value), Pointer(Void).null)
      Native.take_string?(value)
    end

    def self.read_property(pointer : Void*, name : String, type : T.class) : T forall T
      value = T.zero
      C.g_object_get(pointer, name, pointerof(value), Pointer(Void).null)
      value
    end

    def self.write_property(pointer : Void*, name : String, value : Bool) : Nil
      C.g_object_set(pointer, name, value ? 1 : 0, Pointer(Void).null)
    end

    def self.write_property(pointer : Void*, name : String, value : String?) : Nil
      C.g_object_set(pointer, name, Native.string(value), Pointer(Void).null)
    end

    def self.write_property(pointer : Void*, name : String, value : Int32 | UInt32 | Float64) : Nil
      C.g_object_set(pointer, name, value, Pointer(Void).null)
    end

    def disconnect(handler : UInt64) : Nil
      C.g_signal_handler_disconnect(to_unsafe, handler)
    end

    protected def connect(signal : String, callback : Void*, data : Void*) : UInt64
      C.g_signal_connect_data(to_unsafe, signal, callback, data, Handles::RELEASE_CLOSURE, 0).to_u64
    end

    macro properties(table)
      {% for key, type in table %}
        {% property = key.id.stringify.gsub(/_/, "-") %}
        {% if type.stringify == "Bool" %}
          def {{key.id}}? : Bool
            GObject.read_property(to_unsafe, {{property}}, Bool)
          end
        {% elsif type.stringify == "String" %}
          def {{key.id}} : String?
            GObject.read_property(to_unsafe, {{property}}, String)
          end
        {% else %}
          def {{key.id}} : {{type}}
            GObject.read_property(to_unsafe, {{property}}, {{type}})
          end
        {% end %}

        def {{key.id}}=(value : {{type}}{% if type.stringify == "String" %}?{% end %})
          GObject.write_property(to_unsafe, {{property}}, value)
        end
      {% end %}
    end

    macro notify(name, property, type)
      {% value_type = type.stringify == "String" ? "String?".id : type %}
      def on_{{name.id}}_changed(&block : {{value_type}} -> Nil) : UInt64
        %callback = ->(instance : Void*, _spec : Void*, data : Void*) {
          begin
            Box(Proc({{value_type}}, Nil)).unbox(data).call(GObject.read_property(instance, {{property}}, {{type}}))
          rescue ex
            ex.inspect_with_backtrace(STDERR)
          end
          nil
        }
        connect("notify::" + {{property}}, %callback.pointer, Handles.retain(block))
      end
    end

    macro signal(name, signal_name, params = nil, returns = Nil, detailed = false)
      {%
        args = params || {} of Nil => Nil
        raws = [] of ASTNode
        converts = [] of ASTNode
        types = [] of ASTNode
        args.each do |key, type|
          kind = type.stringify
          types << type
          if kind == "Bool"
            raws << "#{key.id} : Int32".id
            converts << "(#{key.id} != 0)".id
          elsif kind == "String"
            raws << "#{key.id} : UInt8*".id
            converts << "String.new(#{key.id})".id
          elsif %w(Int32 UInt32 UInt64 Float64).includes?(kind)
            raws << "#{key.id} : #{type}".id
            converts << key.id
          elsif kind == "Pointer(Void)"
            raws << "#{key.id} : Void*".id
            converts << key.id
          else
            resolved = type.resolve?
            if resolved && resolved < ::Enum
              raws << "#{key.id} : Int32".id
              converts << "#{type}.new(#{key.id})".id
            else
              raws << "#{key.id} : Void*".id
              converts << "#{type}.from_raw(#{key.id})".id
            end
          end
        end
        result = returns.stringify
        block_return = result == "Nil" || result == "Bool" ? returns : "#{returns}?".id
      %}
      def on_{{name.id}}({% if detailed %}detail : String, {% end %}&block : {{types.splat}} -> {{block_return}}) : UInt64
        %callback = ->(instance : Void*, {{raws.splat}}{% unless raws.empty? %}, {% end %}data : Void*) {
          begin
            %value = Box(Proc({{types.splat}}{% unless types.empty? %}, {% end %}{{block_return}})).unbox(data).call({{converts.splat}})
            {% if result == "Nil" %}
              nil
            {% elsif result == "Bool" %}
              %value ? 1 : 0
            {% else %}
              %value ? C.g_object_ref(%value.to_unsafe) : Pointer(Void).null
            {% end %}
          rescue ex
            ex.inspect_with_backtrace(STDERR)
            {% if result == "Nil" %}
              nil
            {% elsif result == "Bool" %}
              0
            {% else %}
              Pointer(Void).null
            {% end %}
          end
        }
        connect({% if detailed %}{{signal_name}} + "::" + detail{% else %}{{signal_name}}{% end %}, %callback.pointer, Handles.retain(block))
      end
    end
  end
end
