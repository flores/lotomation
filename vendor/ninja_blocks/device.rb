module NinjaBlocks
  class Device < Base
    
    class SubDevice < Base
      
      ATTRIBUTE_MAP = {
        :id        => :id,
        :category  => :category,
        :shortName => :short_name,
        :type      => :type,
        :data      => :data
      }
      
      ATTRIBUTE_MAP.values.each { |v| attr_reader(v) }
      
      attr_reader :guid
      
      def initialize(id, parent, d)
        @id       = id
        @parent   = parent
        @raw_data = d
        ATTRIBUTE_MAP.each do |api_name, attr_name|
          self.instance_variable_set("@#{attr_name}", d[api_name.to_s])
        end
      end
      
      def inspect
        %Q{#<NinjaBlocks::Device name="#{short_name}" category="#{category}" type="#{type}">}
      end
      
    end
    
    class << self
      
      def list(filter_by=nil, options={})
        hash_of_response = get("/devices")
        devices = []

        devices = []
        hash_of_response['data'].each do |d|
          device_hash = {}
          device_hash['guid'] = d[0]
          device_hash.merge!(d[1])
          next unless device_matches_filter?(device_hash, filter_by)
          devices << device_hash
          break if options[:find_first]
        end

        instances = devices.map { |d| new(d['guid'], d) }
        options[:find_first] ? instances.first : instances
      end
      
      def find(filter_by)
        list(filter_by, :find_first => true)
      end
      
      def available_types
        list.map(&:type).uniq
      end
      
      protected
      
      def device_matches_filter?(hash, filter_by)
        return true if filter_by.nil?

        type, tag = filter_by[:device_type], filter_by[:tag]
        device_tags = hash['tags'].split(/\s+/)
        
        return false if (type && hash['device_type'] != type)
        return false if (tag  && !device_tags.include?(tag.to_s))
        true
      end
      
    end
    
    # We want to normalize the names we get from the API; some of them are
    # camelCased. So let's map them to snake-cased equivalents.
    ATTRIBUTE_MAP = {
      :guid                => :guid,
      :device_type         => :device_type,
      :default_name        => :default_name,
      :shortName           => :short_name,
      :tags                => :tags,
      :is_sensor           => :is_sensor,
      :is_actuator         => :is_actuator,
      :is_silent           => :is_silent,
      :has_time_series     => :has_time_series,
      :has_subdevice_count => :has_subdevice_count,
      :has_state           => :has_state,
      :subDevices          => :sub_devices,
      :last_data           => :last_data
      # TODO: More attributes.
    }
    
    ATTRIBUTE_MAP.values.each { |v| attr_reader v }
    
    def initialize(guid, d=nil)
      @guid = guid
      set_attributes(d)
    end
    
    def inspect
      %Q{#<NinjaBlocks::Device name="#{short_name}" device_type="#{device_type}">}
    end
    
    def short_name
      return @device_name if @short_name.nil? || @short_name.empty?
      @short_name
    end
    
    def sensor?
      @is_sensor == 1
    end
    
    def actuator?
      @is_actuator == 1
    end
    
    def silent?
      @is_silent == 1
    end
    
    def actuate(da)
      raise "Not an actuator!" unless actuator?
      json = JSON.dump('DA' => da)
      put("/device/#{guid}", json)
    end
    
    def actuate_local(local_ip, da)
      json = JSON.dump('DA' => da)
      put("http://#{local_ip}:8000/rest/v0/device/#{guid}", json)
    end
    
    def subscribe(url, options={})
      self.unsubscribe if options[:unsubscribe]
      json = JSON.dump('url' => url)
      post("/device/#{guid}/callback", json)
    end
    
    def unsubscribe
      delete("/device/#{guid}/callback")
    end
    
    def data(params={})
      [:from, :to].each do |key|
        params[key] = interpret_date(params[key]) if params.has_key?(key)
      end
      get("/device/#{guid}/data", params)
    end
    
    def last_heartbeat
      response = get("/device/#{guid}/heartbeat")
      response['data']
    end
    
    
    protected
        
    def set_attributes(d)
      if d.nil?
        # If we have no data, it means the user instantiated with a GUID. Get
        # the rest of the data for this device.
        response = get("/device/#{guid}")
        d = response['data'] if response
      end

      @raw_data = d

      ATTRIBUTE_MAP.each do |api_name, attr_name|
        self.instance_variable_set("@#{attr_name}", d[api_name.to_s])
      end
      
      if @sub_devices && @sub_devices.any?
        sds = @sub_devices
        @sub_devices = sds.map { |sd_id, sd_data| SubDevice.new(sd_id, guid, sd_data) }
      end
    end
    
  end
end


