class Tormenta20::CharacterSheetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_tormenta20_character_sheet, only: %i[ show update destroy ]

  # GET /tormenta20/character_sheets
  def index
    @tormenta20_character_sheets = Tormenta20::CharacterSheet.all

    render json: @tormenta20_character_sheets
  end

  # GET /tormenta20/character_sheets/1
  def show
    render json: @tormenta20_character_sheet
  end

  # POST /tormenta20/character_sheets
  def create
    @tormenta20_character_sheet = Tormenta20::CharacterSheet.new(tormenta20_character_sheet_params)

    if @tormenta20_character_sheet.save
      render json: @tormenta20_character_sheet, status: :created, location: @tormenta20_character_sheet
    else
      render json: @tormenta20_character_sheet.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tormenta20/character_sheets/1
  def update
    if @tormenta20_character_sheet.update(tormenta20_character_sheet_params)
      render json: @tormenta20_character_sheet
    else
      render json: @tormenta20_character_sheet.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tormenta20/character_sheets/1
  def destroy
    @tormenta20_character_sheet.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tormenta20_character_sheet
      @tormenta20_character_sheet = Tormenta20::CharacterSheet.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tormenta20_character_sheet_params
      params.expect(tormenta20_character_sheet: [ :name, :description, :data, :temp ])
    end
end
