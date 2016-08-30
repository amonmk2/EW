#! ruby
# coding: utf-8

require 'erb'
require 'csv'

module ReportBuilder

	module Context

		##
		## エラーワーニングメッセージ処理を行うクラス
		##
		class ErrorWarning

			attr_accessor :mode, :message_rule, :stage_state, :template_html, :rule

			def initialize ()
				# HASH初期化
				@hash = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } } }
				@rule = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } }

				# インスタンス変数　初期値
				#　ログのステージ名と判定用の正規表現
				@stage_state =  {"stage1" => /^# stage1/ ,"stage2" => /^# stage2/,"stage3" => /^# stage3/ }
				# エラーワーニングメッセージのコード、メッセージ部分の正規表現
				@message_rule = /(ERROR|WARNING)\s*\(([a-zA-Z0-9\-]+)\) (.+)$/
				@error_rule = "ERROR"
				@warning_rule = "WARNING"
				# HTMLテンプレートファイル
			  @template_html = "layout/table_html.erb"
			  #　出力モード : all :全て  or メッセージ文字列"ERROR""WARNING"
			  @mode = "all"
			end	

			def read(rule_csv,txt)
				self.read_rule(rule_csv)
				self.read_log(txt)
			end

		  # rule 読み込み
		 	# ルールファイルを読み込む
			# @param [rule_csv] rule_csv ルールファイル  
			def read_rule (rule_csv)
				#		CSV.foreach(rule_csv, headers: true, row_sep: "\r\n", encoding: 'Shift_JIS:UTF-8'){ |row|
				CSV.foreach(rule_csv){ |row|
					stage = row[0]
		 			code  = row[1]
		 			jadge = row[2]
		 			msg   = row[4]
		  		@rule[stage][code] = [ jadge, msg ]
				}
			end

			#　ログを読み込む
			def read_log (txt)
				state = ""
				File.foreach(txt) do |line|
					@stage_state.each_key { |stg| 
						if line =~ @stage_state[stg]
							state = stg 
						else 
							state = state
						end
					}				
					# メッセージを取り出してハッシュへ格納
					if line =~ @message_rule
						ew = $1
						code = $2
						msg = $3
						# stage hash
						@hash["#{state}"][ew][code].push(msg)
					end
				end
			end

			# 指定したステージ毎にHTMLを出力する
			# @param [stage] stage ステージ名 
			def table_html(stage)
				ERB.new(File.read(@template_html),nil,'-').result(binding)
			end

			#　すべてのステージのHTMLを出力する
			def table_html_page
				@page = ""
				@stage_state.each_key { |stage| @page << self.table_html(stage) }
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
