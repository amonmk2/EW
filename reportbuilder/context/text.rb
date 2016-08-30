#! ruby
# coding: utf-8

require 'erb'


module ReportBuilder

  module Context

    ##
    ##　テキストレポートを作成するクラス
    ##
    class Text
     
      attr_accessor :rep_option, :template_html, :texts

      def initialize
        @template_html = "layout/text_html.erb"
        @rep_option = Hash.new {|hash, key| hash[key] = 'collapse:true;'}
        @texts = Hash.new {|hash, key| hash[key] = ""}
      end

      def read(text_file , pattern: //)
      	File.foreach(text_file) { |line| @texts[text_file] << line }
      	unless pattern.source.empty?  
      	  line_numbers = []
      	  cnt = 0
          @texts[text_file].each_line { |line|  cnt+=1; line_numbers.push(cnt) if line.match(pattern) }
          @rep_option[text_file] = "highlight:#{line_numbers};"
        end
      end

      def to_plain_txt(text_file , pattern: //)
        self.read(text_file, pattern: pattern) 
        @page = ERB.new(File.read(@template_html),nil,'-').result(binding)
      end 

      def read_texts(*text_files)
        text_files.each { |txt| self.read(txt) }
      end

      def to_plain_txts(*text_files)
        text_files.each { |txt| self.read(txt) } 
        @page = ERB.new(File.read(@template_html),nil,'-').result(binding)
      end 

      def get_binding
        call_binding { @page }
      end

      private

      def call_binding
        binding
      end

    end

  end 

end
