class ScenariosController < ApplicationController
  before_action :set_scenario, only: [:show, :edit, :update, :destroy, :test_results]
  before_action :set_project, only: [:index, :show, :new, :create, :edit, :update]

  # GET /scenarios
  # GET /scenarios.json
  def index
    @scenarios = Scenario.where(project_id: params[:project_id]).order(:scenario_no, :updated_at)
  end

  # GET /scenarios/1
  # GET /scenarios/1.json
  def show
    @test_cases = @scenario.test_cases
  end

  # GET /scenarios/new
  def new
    @scenario = Scenario.new
  end

  # GET /scenarios/1/edit
  def edit
    @test_cases = @scenario.test_cases
    input_scenario = ""
    
    @test_cases.each do |test|
      if input_scenario.blank?
        input_scenario += "^#{test.screen_name}\n^#{test.test_content}\n^#{test.check_content}\n¥#{test.status}\n;"
      else
        input_scenario += "\n\n^#{test.screen_name}\n^#{test.test_content}\n^#{test.check_content}\n¥#{test.status}\n;"
      end
    end
    
    @scenario.input_scenario = input_scenario
  end

  # POST /scenarios
  # POST /scenarios.json
  def create
    @scenario = Scenario.new(scenario_params)
    @scenario.project_id = params[:project_id]

    if params[:preview_button]
      if preview
        render 'preview' and return
      else
        render 'error' and return
      end
    end  

    respond_to do |format|
      if @scenario.save
        splitTest = @scenario.input_scenario.split(ROW_MARK)
        rowCount = 1
        
        splitTest.each do |testCase|

          splitTestCase = testCase.split(COL_MARK)
          
          TestCase.create(scenario_id: @scenario.id, test_case_no: rowCount, screen_name: splitTestCase[1].gsub(/\R$/, "") ,
            test_content: splitTestCase[2].gsub(/\R$/, ""), check_content: splitTestCase[3].gsub(/\R$/, ""), status: "0")
          
          rowCount += 1
        end
 
        @scenario.count_item = @scenario.test_cases.count
        @scenario.count_item_target = @scenario.count_item
        @scenario.count_remaining = @scenario.count_item
        @scenario.save
        
        format.html { redirect_to @scenario, notice: 'Scenario was successfully created.' }
        format.json { render :show, status: :created, location: @scenario }
      else
        render 'error' and return
      end
    end
  end

  # PATCH/PUT /scenarios/1
  # PATCH/PUT /scenarios/1.json
  def update

    if params[:preview_button]
      if preview
        render 'preview' and return
      else
        render 'error' and return
      end
    end     

    respond_to do |format|
      if @scenario.update(scenario_params)

        rowCount = 1
        splitTest = @scenario.input_scenario.split(ROW_MARK)
        
        TestCase.destroy_all(scenario_id: @scenario.id)
        
        splitTest.each do |testCase|

          splitTestCase = testCase.split(COL_MARK)
          
          splitStatus = splitTestCase[3].split(STATUS_MARK)
          status = splitStatus[1].presence || "0"
            
          TestCase.create(scenario_id: @scenario.id, test_case_no: rowCount, screen_name: splitTestCase[1].gsub(/\R$/, "") ,
            test_content: splitTestCase[2].gsub(/\R$/, ""), check_content: splitStatus[0].gsub(/\R$/, ""), status: status.gsub(/\R$/, ""))
          
          rowCount += 1
        end
 
        @scenario.count_item = @scenario.test_cases.count
        @scenario.count_item_target = @scenario.count_item - @scenario.test_cases.where(status: ["4"]).count
        @scenario.count_ok = @scenario.test_cases.where(status: ["1","3"]).count
        @scenario.count_ng = @scenario.test_cases.where(status: ["2","3"]).count
        @scenario.count_remaining = @scenario.count_item_target - @scenario.test_cases.where(status: ["1","3"]).count
        @scenario.save

        
        format.html { redirect_to @scenario, notice: 'Scenario was successfully updated.' }
        format.json { render :show, status: :ok, location: @scenario }
      else
        render 'error' and return
      end
    end
  end

  # DELETE /scenarios/1
  # DELETE /scenarios/1.json
  def destroy
    @scenario.destroy
    respond_to do |format|
      format.html { redirect_to project_scenarios_url(@scenario.project_id), notice: 'Scenario was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def test_results
    
    respond_to do |format|

      if @scenario.update(test_case_params)
        @scenario.count_item_target = @scenario.test_cases.size - @scenario.test_cases.where(status: ["4"]).count
        @scenario.count_ok = @scenario.test_cases.where(status: ["1","3"]).count
        @scenario.count_ng = @scenario.test_cases.where(status: ["2","3"]).count
        @scenario.count_remaining = @scenario.count_item_target - @scenario.count_ok
        @scenario.save
        
        format.html { redirect_to @scenario, notice: 'ステータスを更新しました' }
      else
        format.html { redirect_to @scenario, notice: 'ステータスの更新に失敗しました' }
      end
    end    
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scenario
      @scenario = Scenario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scenario_params
      params.require(:scenario).permit(:scenario_name, :scenario_no, :description, :input_scenario)
    end

    def test_case_params
      params.require(:scenario).permit(test_cases_attributes: [:status, :id])
    end
    
    def set_project
      params[:project_id].present? ? @project = Project.find(params[:project_id]) : @project = Project.find(@scenario.project_id)
    end
    
    def preview
      test = Scenario.new(scenario_params).input_scenario
      
      rowCount = 1
      splitTest = test.split(ROW_MARK)
      previewTest = []
      
      splitTest.each do |testCase|

        splitTestCase = testCase.split(COL_MARK)

        if splitTestCase.length == 4

          previewTest.push( {:no => rowCount, 
            :screenName => splitTestCase[1].gsub(NEW_LINE_CODE, BR_TAG), 
            :testContent => splitTestCase[2].gsub(NEW_LINE_CODE, BR_TAG), 
            :checkContent => splitTestCase[3].split('¥')[0].gsub(NEW_LINE_CODE, BR_TAG)} )
                
        else
          if testCase.present?
            flash.now[:alert] = "#{rowCount}項目目のフォーマットが不正な為、プレビューが表示できません"
            return false
          end
        end
          
        rowCount += 1
      end
      puts previewTest      
      @preview =  previewTest
      return true
    end
end