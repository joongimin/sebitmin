module Application
  module Enum
    def initialize(key, value)
      @key = key
      @value = value
    end
 
    def key
      @key
    end
 
    def value
      @value
    end
  
    def self.included(base)
      base.extend(ClassMethods)    
    end
 
    module ClassMethods
      def define(key, value)
        @hash ||= {}
        @hash[key] = value
        
        @array ||= []
        @array << [key, value]
      end
 
      def const_missing(key)
        @hash[key]
      end    
 
      def each
        @array.each do |element|
          key = element[0]
          value = element[1]
          yield key, value
        end
      end
 
      def all
        @hash.values
      end
      
      def collect
        @hash.collect
      end
 
      def all_to_hash
        hash = {}
        each do |key, value|
          hash[key] = value.value
        end
        hash
      end
      
      def t(key)
        I18n.t("#{self.to_s.underscore}.#{key}")
      end
    end
  end
end