namespace :user do
  
  desc "get all photos, photosets, tags, comments, and photo metadata for the given username"
  task :get_all, :username, :force, :needs => :environment do |t,args|
    args.with_defaults(:force => false)
    u = User.find_by_username(args.username)
    u.get_all(args.force)
  end
  
  task :verbose, :needs => :environment do
    puts "VERBOSE: #{Toastflickr::Application::config.verbose}"
  end
  
  namespace :admin do
  
    desc "add a new userid"
    task :add, :user_id, :needs => :environment do |t,args|
      u = User.find_or_initialize_by_flickr_user_id args.user_id
      if u.save
        puts "saved user #{args.user_id}"
      end
    end
  
    desc "generate a link for authorizing the given userid"
    task :get_auth_link, :user_id, :needs => :environment do |t,args|
      u = User.find_or_initialize_by_flickr_user_id(args.user_id)
      puts u.get_auth_link
    end
  
    desc "after visiting the auth link, grab the token for the given userid"
    task :get_token, :user_id, :needs => :environment do |t,args|
      u = User.find_by_flickr_user_id(args.user_id)
      u.get_token  # get the token via the frob
      puts "saved token #{u.token} for user #{args.user_id}"
    end
  end # namespace :admin
  

  
end # namespace :user
