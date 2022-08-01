class DogsController < ApplicationController
  before_action :verified_staff

  def index
    @dogs = Dog.where(organization_id: current_user.staff_account.organization_id)
  end

  def new
    @dog = Dog.new
  end

  def edit
    @dog = Dog.find(params[:id])
    return if same_organization?(@dog)

    redirect_to dogs_path, notice: 'Staff can only interact with dogs in their organization.'
  end

  def show
    @dog = Dog.find(params[:id])
    return if same_organization?(@dog)

    redirect_to dogs_path, notice: 'Staff can only interact with dogs in their organization.'
  end

  def create
    @dog = Dog.new(dog_params)

    if @dog.save
      redirect_to dogs_path, notice: 'Dog saved successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @dog = Dog.find(params[:id])

    if same_organization?(@dog) && @dog.update(dog_params)
      redirect_to @dog
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dog = Dog.find(params[:id])

    if same_organization?(@dog) && @dog.destroy
      redirect_to dogs_path, status: :see_other
    else
      redirect_to root_path, notice: 'Error.'
    end
  end

  private

  def dog_params
    params.require(:dog).permit(:organization_id, :name, :age)
  end

  # check before all actions that user has staff account
  def verified_staff
    return if current_user.staff_account.verified

    redirect_to root_path, notice: 'Unauthorized action.'
  end

  # use in update and destroy to ensure staff belongs to same org as dog
  def same_organization?(dog)
    current_user.staff_account.organization_id == dog.organization_id
  end

end
