#! ruby
# coding: utf-8

require 'erb'

module ReportBuilder 

	  def to_html(output_file , data)
	  	File.open(output_file , "w") do |file|
	  		file.write data
	  	end
	  end

	##
	## レポートページをまとめて作成するクラス
	##

	class Top

		attr_accessor :ew_output_file , :text_output_file , :index_output_file , :graph_output_file

		def initialize(template)
	   	@template = ERB.new(File.read(template), nil, "-")
			@ew_output_file = "ew.html"
			@text_output_file = "text.html"
			@index_output_file = "index.html"
			@graph_output_file = "graph.html"
		end

		#　エラーワーニングログ用
	  def build_err_warn(rule,log,mode="all",template="")
	   	context = Context::ErrorWarning.new
	    context.template_html = template unless template.empty?
	    context.mode = mode
	   	context.read(rule,log)
	   	context.table_html_page
#	   	@template.run(context.get_binding)
	   	File.open(@ew_output_file , "w") do |file|
	  		file.puts @template.result(context.get_binding)
	  	end
	  end

	  # D3.js scatterグラフ生成
	  def build_graph(csv)
	  	context = Context::Graph.new
	  	context.csv = csv
	  	context.to_scatter
	   	@template.run(context.get_binding)
	   	File.open(@graph_output_file , "w") do |file|
	  		file.puts @template.result(context.get_binding)
	  	end
	  end

	  def build_text_rep(pattern,txt)
	  	context = Context::Text.new
	  	context.to_plain_txt(txt, pattern: pattern)
#	   	@template.run(context.get_binding)
	   	File.open(@text_output_file , "w") do |file|
	  		file.puts @template.result(context.get_binding)
	  	end
	  end

	  def build_texts_rep(*txts)
	  	context = Context::Text.new
	  	context.to_plain_txts(*txts)
#	   	@template.run(context.get_binding)
	   	File.open(@text_output_file , "w") do |file|
	  		file.puts @template.result(context.get_binding)
	  	end
	  end

	  #　インデックスページ作成
	 	def build_index(index)
			context = Index.new
			context.index = index
			context.to_index
			#@template.run(context.get_binding)
	   	File.open(@index_output_file , "w") do |file|
	  		file.puts @template.result(context.get_binding)
	  	end
	 	end

	 	def build_all()
	  		
	 	end

	end 


end