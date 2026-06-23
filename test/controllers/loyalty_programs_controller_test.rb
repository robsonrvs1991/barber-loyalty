require "test_helper"

class LoyaltyProgramsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @loyalty_program = loyalty_programs(:one)
  end

  test "should get index" do
    get loyalty_programs_url
    assert_response :success
  end

  test "should get new" do
    get new_loyalty_program_url
    assert_response :success
  end

  test "should create loyalty_program" do
    assert_difference("LoyaltyProgram.count") do
      post loyalty_programs_url, params: { loyalty_program: { barbershop_id: @loyalty_program.barbershop_id, required_visits: @loyalty_program.required_visits, reward_description: @loyalty_program.reward_description } }
    end

    assert_redirected_to loyalty_program_url(LoyaltyProgram.last)
  end

  test "should show loyalty_program" do
    get loyalty_program_url(@loyalty_program)
    assert_response :success
  end

  test "should get edit" do
    get edit_loyalty_program_url(@loyalty_program)
    assert_response :success
  end

  test "should update loyalty_program" do
    patch loyalty_program_url(@loyalty_program), params: { loyalty_program: { barbershop_id: @loyalty_program.barbershop_id, required_visits: @loyalty_program.required_visits, reward_description: @loyalty_program.reward_description } }
    assert_redirected_to loyalty_program_url(@loyalty_program)
  end

  test "should destroy loyalty_program" do
    assert_difference("LoyaltyProgram.count", -1) do
      delete loyalty_program_url(@loyalty_program)
    end

    assert_redirected_to loyalty_programs_url
  end
end
