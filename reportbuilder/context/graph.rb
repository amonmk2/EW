#! ruby
# coding: utf-8

require 'erb'


module ReportBuilder

  module Context

    ##
    ## グラフ生成を行うクラス
    ##
    class Graph

      attr_accessor :csv, :template_html

      def initialize()
        @template_html = "layout/graph_html.erb"
        @csv = ""
      end

      def to_scatter
      	title = "scatter"
        @page = ERB.new(File.read(@template_html),nil,'-').result(binding)
      end
    		
      # ERBのバインディング用
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
