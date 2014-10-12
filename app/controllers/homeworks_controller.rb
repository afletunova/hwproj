class HomeworksController < ApplicationController
  before_action :set_assignment, only: [ :edit, :update, :destroy ]

  def new
    @assignment = Homework.new
  end

  def create
    @assignment = Homework.new(assignment_params)
    @assignment.number = @assignment.term.assignments.select{|x| x.assignment_type == @assignment.assignment_type}.count + 1
    @assignment.save
    enumerate_problems
    create_jobs_and_tasks
    redirect_to @assignment.term.course
  end

  def edit
  end

  def update
    enumerate_problems
    
    @assignment.problems.each do |problem|
      unless Task.where(problem_id: problem.id).any?
        @assignment.jobs.each do |job|
          job.tasks.create(problem_id: problem.id)
        end
      end
    end
  end

  def destroy
    term = @assignment.term

  end

  private
    def assignment_params
      params.require(:homework).permit(:assignment_type, :term_id, problems_attributes: [ :id, :text, :_destroy ], links_attributes: [ :id, :url, :name, :_destroy ])
    end

    def enumerate_problems
      problems = @assignment.problems
      for i in 1..problems.count
        problems[i - 1].update(number: i)
      end
    end

    def create_jobs_and_tasks
      @assignment.term.students.each do |student|
        job = student.jobs.create(homework_id: @assignment.id)

        @assignment.problems.each do |problem|
          job.tasks.create(student_id: job.student.id, user_id: student.user.id, problem_id: problem.id)
        end
      end
    end

    def set_assignment
      @assignment = Homework.find(params[:id])      
    end
end


# class HomeworksController < ApplicationController
#   before_action :set_homework, only: [ :edit, :update, :destroy ]
#   before_action :check_teacher, only: [ :new, :edit ]

#   def new
#     @homework = Homework.new()
#   end

#   def create
#     @homework = Homework.new(homework_params)
#     if @homework.valid?
#       @homework.number = @homework.group.homeworks.count + 1
#       @homework.save
#       create_jobs
#       redirect_to edit_homework_path(@homework)
#     else
#       redirect_to :back
#     end
#   end

#   def index
#     @homeworks = Homework.all
#   end

#   def edit
#   end

#   def update
#     if @homework.valid?
#       @homework.update(homework_params)
#       enumerate_problems
#       create_tasks
#       redirect_to @homework.group
#     else
#       redirect_to :back
#     end
#   end

#   def destroy
#     group = @homework.group
#     @homework.destroy

#     group_homeworks = @homework.group.homeworks
#     for i in 0..group_homeworks.count - 1
#       group_homeworks[i].update(number: i + 1)
#     end

#     redirect_to group
#   end

#   private

#     def set_homework
#       @homework = Homework.find(params[:id])
#     end

#     def check_teacher
#       if (not signed_in?) || (not current_user.teacher?)
#         raise ActionController::RoutingError.new('Not Found')
#       end
#     end

#     def homework_params
#       params.require(:homework).permit(:number, :group_id, problems_attributes: [ :id, :text, :_destroy ], links_attributes: [ :id, :url, :name, :_destroy ])
#     end

#   def enumerate_problems
#     problems = @homework.problems
#     for i in 0..problems.count - 1
#       problems[i].update(number: i + 1)
#     end
#   end

#   def create_jobs
#     @homework.group.users.each do |user|
#       user.jobs.create(homework_id: @homework.id)
#     end
#   end

#   def create_tasks
#     @homework.group.users.each do |user|
#       job = user.jobs.find_by(homework_id: @homework.id)

#       @homework.problems.each do |problem|
#         user.tasks.create(problem_id: problem.id, homework_id: problem.homework_id, job_id: job.id)
#       end
#     end
#   end
# end
