class Team < ApplicationRecord
    has_and_belongs_to_many :managers
    has_and_belongs_to_many :users
    has_many :surveys
    has_many :tickets

    validates :name, length: {in: 1..50}, presence: true, allow_blank: false
    
    def get_survey_completion_ratio(current_weekly_survey_due_date)
       completed_surveys = 0
       users.each do |user|
         survey = Survey.find_by(user_id: user.id, team_id: id, date: current_weekly_survey_due_date)
         if survey && survey.responses.exists?
           completed_surveys += 1
         end
       end
       return "#{completed_surveys}/#{users.count}"
    end
    
    def weekly_survey_team_health(week, current_weekly_survey_due_date)
      count_numerator = 0
      count_total = 0
      surveysToCalc = Survey.where(:team_id => id, :date => current_weekly_survey_due_date-week*7)
      surveysToCalc.each do |survey|
          survey.responses.each do |response|
            count_numerator += response.answer
            count_total += 1 
          end
      end
     
      if count_total == 0
        return 0
      else
        count_denominator = count_total*5
        return '%.2f' % ((count_numerator.to_f/count_denominator.to_f)*100)
      end
    end
    
    def weekly_feedback_team_health(week, current_weekly_survey_due_date)
        count_communication = 0
        count_behaviour = 0
        count_teamwork = 0
        count_availability = 0
        count_rating = 0
        weekly_feedback = [count_communication, count_behaviour, count_teamwork, count_availability, count_rating]
        count_total = 0
        start_date = current_weekly_survey_due_date-week*7
        tickets = Ticket.where(:date => start_date-7...start_date, :team => id)
        tickets.each do |ticket|
            if ticket.ticket_responses.exists?
                # break up each ticket response
              weekly_feedback[0] += ticket.ticket_responses.first.answer
              weekly_feedback[1] += ticket.ticket_responses.second.answer
              weekly_feedback[2] += ticket.ticket_responses.third.answer
              weekly_feedback[3] += ticket.ticket_responses.fourth.answer
              weekly_feedback[4] += ticket.ticket_responses.fifth.answer
              count_total += 1
            end
        end
        weekly_feedback << count_total
        if count_total == 0
          return []
        else
            # raw sum of feedback data
          return weekly_feedback
        end
    end
    
    def get_total_team_health(week, current_weekly_survey_due_date)
        weekly_survey_team_health = self.weekly_survey_team_health(week, current_weekly_survey_due_date)
        weekly_feedback_team_health = self.weekly_feedback_team_health(week, current_weekly_survey_due_date)
        if (weekly_survey_team_health == 0) 
            return sum_weekly_feedback_team_health(weekly_feedback_team_health)
        elsif (weekly_feedback_team_health == [])
            return weekly_survey_team_health
        else 
            calculated_weekly_feedback_health = sum_weekly_feedback_team_health(weekly_feedback_team_health)
            return '%.2f' % (0.8*(weekly_survey_team_health.to_f) + 0.2*(calculated_weekly_feedback_health.to_f))
        end
    end
    
    def get_health_history(current_weekly_survey_due_date)
      total_weeks = Survey.where(team_id: id).select('distinct(date)').count
      @team_health_history = []
      for i in 0..total_weeks - 1 do 
        due_date = current_weekly_survey_due_date - 7*i
        @team_health_history << ["#{due_date-7} - #{due_date-1}", self.get_total_team_health(i, current_weekly_survey_due_date)]
      end  
      return @team_health_history
    end
    
    # privately calculate the total feedback health
    private
    
    def sum_weekly_feedback_team_health(feedbacks)
        if feedbacks == []
            return 0
        else
            sum_weekly_feedback = 0.00
            # exclude the total count and rating
            for i in 0..feedbacks.length-3
                # calculate average in category responses and give weight of 10%
                feedbacks[i] = (feedbacks[i].to_f/feedbacks[5].to_f*3)*0.1
            end
            # calculate average in rating responses and give weight of 60%
            feedbacks[4] = (feedbacks[4].to_f/feedbacks[5].to_f*10)*0.6
            sum_weekly_feedback = 0.00
            for i in 0..feedbacks.length-1
                sum_weekly_feedback += feedbacks[i]
            end
            return sum_weekly_feedback
        end
    end
end
