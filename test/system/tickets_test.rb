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
    
  test "can access create ticket from user dashboard" do
    visit login_path
    fill_in "watiam", with: @user_1.watiam
    fill_in "password", with: @user_1.password
    click_on "Login"
    click_on "Create Ticket"
    assert_text "New Ticket"
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
    
    # can view the details of a ticket and the feedback that a student gave another student
    # Story: Update manager's view of all tickets
  test "can successfully view ticket's details as a manager" do
    visit login_path
    fill_in "watiam", with: @manager_1.watiam
    fill_in "password", with: @manager_1.password
    click_on "Login"
    click_on "View All Tickets"
    click_on @t_1.id
    assert_text "Date Created:"
  end
    
# can successfully send a ticket to another student 
# Story: Change ticket creation from textual feedback to peer rating
  test "creating a Ticket" do
    user2 = User.create(watiam: "jellen", first_name: "Joe", last_name: "Ellen", password: "Password")
    @team_1.users << user2
    visit login_path
    fill_in "watiam", with: @user_1.watiam
    fill_in "password", with: @user_1.password
    click_on "Login"
    visit new_team_ticket_url(@team_1)
    assert_text "New Ticket"
    select "jellen: Joe Ellen", :from => :users
    click_on "Save"

    assert_text "Ticket was successfully created"
  end
    
# is redirected when trying to access a create ticket page for a team they are not on
# Story: Bug Bash: Creating a Ticket if you're not on the team
    test "redirect if not on team to create a ticket" do
        user_5 = User.create(watiam: "u5", first_name: "user5", last_name: "five", password: "Password")
        visit login_path
        fill_in "watiam", with: user_5.watiam
        fill_in "password", with: user_5.password
        click_on "Login"
        visit new_team_ticket_url(@team_1)
        assert_text "You do not have permission to create this ticket"
    end
end
