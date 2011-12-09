class MessagesController < ApplicationController
  layout 'plain'
  before_filter :login_required, :only => [:new, :wizard, :create]

  # Retrieves all conversations
  def index
    @results = Heypal::Message.list({"access_token" => current_token})
  end

  # Retrieves all messages with a user
  def conversation
    @with = Heypal::User.info("id" => params[:id])
    @messages  = Heypal::Message.messages({"id" => params[:id],"access_token" => current_token})
  end

  # Posts a new message to a user
  def create
    message_params = {}
    message_params.merge!({:access_token => current_token, :id => params['id'], :message => params['message']['message']})
    @message = Heypal::Message.create(message_params)

    render :partial => '/comments/add_message'
  end

  def delete_conversation
    @with = Heypal::User.info("id" => params[:id])
    @deleted, @result = Heypal::Message.delete('user_id' => params['id'], 'access_token' => current_token)

    flash[:notice] = "Conversation with #{@with['first_name'].chr}. #{@with['last_name']} deleted."
    redirect_to messages_path
  end
end
