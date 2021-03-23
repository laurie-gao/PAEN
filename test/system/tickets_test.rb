require "application_system_test_case"
require 'test_helper'

class TicketsTest < ApplicationSystemTestCase
  setup do
    setup_tickets_with_responses
  end

    # from users POV
  test "visiting the create ticket form" do
    visit login_path
    fill_in "watiam", with: @user_1.watiam
    fill_in "password", with: @user_1.password
    click_on "Login"
    visit new_team_ticket_url(@team_1)
    assert_text "New Ticket"
  end
    
  test "can access create ticket from team view" do
    visit login_path
    fill_in "watiam", with: @user_1.watiam
    fill_in "password", with: @user_1.password
    click_on "Login"
    click_on "one"
    assert_text "Create A Ticket"
  end
    
  test "can discard changes and return to dashboard without completing ticket" do
    visit login_path
    fill_in "watiam", with: @user_1.watiam
    fill_in "password", with: @user_1.password
    click_on "Login"
    click_on "one"
    click_on "Create A Ticket"
    click_on "Go Back and Discard Changes"
    assert_text "Welcome " + @user_1.first_name.capitalize + "!"
  end
    
    # from managers POV
  test "can successfully view ticket list as a manager" do
    visit login_path
    fill_in "watiam", with: @manager_1.watiam
    fill_in "password", with: @manager_1.password
    click_on "Login"
    click_on "View All Tickets"
    assert_text "My Team's Tickets"
  end
    
  test "can successfully view ticket's details as a manager" do
    visit login_path
    fill_in "watiam", with: @manager_1.watiam
    fill_in "password", with: @manager_1.password
    click_on "Login"
    click_on "View All Tickets"
    click_on @t_1.id
    assert_text "Date Created:"
  end
    
# TODO: Fix this test
#  test "creating a Ticket" do
#    user2 = User.create(watiam: "jellen", first_name: "Joe", last_name: "Ellen", password: "Password")
#    @team.users << user2
#    visit login_path
#    fill_in "watiam", with: @user.watiam
#    fill_in "password", with: @user.password
#    click_on "Login"
#    visit new_team_ticket_url(@team)
       
#    select(user2, :from => "Users")
#    fill_in :users, with: user2
#    fill_in "answer1", with: 1
#    fill_in "answer2", with: -1
#    fill_in "answer3", with: 0
#    fill_in "answer4", with: 1
#    fill_in "answer5", with: 10
#    click_on "Create Ticket"

#    assert_text "Ticket was successfully created"
#  end

end
