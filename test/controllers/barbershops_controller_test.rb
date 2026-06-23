require "test_helper"

class BarbershopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @barbershop = barbershops(:one)
  end

  test "should get index" do
    get barbershops_url
    assert_response :success
  end

  test "should get new" do
    get new_barbershop_url
    assert_response :success
  end

  test "should create barbershop" do
    assert_difference("Barbershop.count") do
      post barbershops_url, params: { barbershop: { address: @barbershop.address, name: @barbershop.name, phone: @barbershop.phone } }
    end

    assert_redirected_to barbershop_url(Barbershop.last)
  end

  test "should show barbershop" do
    get barbershop_url(@barbershop)
    assert_response :success
  end

  test "should get edit" do
    get edit_barbershop_url(@barbershop)
    assert_response :success
  end

  test "should update barbershop" do
    patch barbershop_url(@barbershop), params: { barbershop: { address: @barbershop.address, name: @barbershop.name, phone: @barbershop.phone } }
    assert_redirected_to barbershop_url(@barbershop)
  end

  test "should destroy barbershop" do
    assert_difference("Barbershop.count", -1) do
      delete barbershop_url(@barbershop)
    end

    assert_redirected_to barbershops_url
  end
end
