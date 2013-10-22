class PathController < ApplicationController
  def show_path
      @answers_array = params[:answers_array]
      if @answers_array.nil? then 
          @answers_array = []
      end
  end

  def customize_path
  end

  def parse_path
    begin
        rules = DynamicPath.new.parse(params)
        recipe_name = params[:recipe_name]
        PathToDb.new.to_db(recipe_name, rules)
        #session[:rules] = rules

        redirect_to recipes_path
    rescue IndexError => e
        logger.error "Error: " + e.to_s
        redirect_to path_customize_path_path, notice: "Error input: Please fill in all branchs."
    end
  end

  def client_form
    #@view_recipe = params[:view_recipe]
    @view_recipe = Recipe.all
    respond_to do |format|
        format.html
        format.json do
            puts "======================================="
            puts "v: " + @view_recipe
            @rules = DbToPath.new.to_path  # TODO need to catch exception when query db
            #@rules = session[:rules]
            render json: @rules.to_json
        end
    end
  end

  Inf = 1.0/0.0
  def parse_client
    ruleValidTo = (1..Inf).each {|x| break x-1 if params.member?("rule" + x.to_s) == false }
    @answers = (1..ruleValidTo).inject([]) {|x,y| x << params["rule" + y.to_s]}
    redirect_to path_show_path_path(answers_array: @answers)
  end

end
