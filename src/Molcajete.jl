__precompile__()

module Molcajete

    import Requests: get, post, put, delete, options, json

    global base_url = "https://api.meetup.com/"

    if !haskey(ENV, "MEETUP_API_TOKEN")
        error("MEETUP_API_TOKEN environment variable is required.")
    end

    # a silly hack required by ImmutableDict
    global default_query_params = Dict("key" => ENV["MEETUP_API_TOKEN"], "signed" => true)

    type Event
        id::Int
        name
        datetime::DateTime
    end
    
    type Meetup
        id::Int
        name
        city
        country
    end

    type MeetupUser 
        id::Int
        name
        link 
        #meetups::Meetup[]
    end

    function show_calendar(meetup_name::String, month::Int, year::Int)
        meetups = find_common_meetups(meetup_name)
        #events = get_events(meetups, month, year) 
        #plot_histogram(events)
    end

    function find_common_meetups(name)
        meetup = get_meetup(name)
        members = get_meetup_members(meetup)
        for mem=members
            println(mem.name)
        end
    end

    function get_meetup(name)
        println("Fetching info for $name meetup.")
        response = get("$base_url$name", query = default_query_params)
        if response.status != 200
            error(response.status)
        end 
        jr = json(response)
        Meetup(jr["id"], jr["urlname"], jr["city"], jr["country"])
    end

    function get_meetup_members(meetup::Meetup)
        println("Fetching meetup members.")
        endpoint = "2/members"

        query = Dict()
        query["group_urlname"] = meetup.name
        for (key, value) in default_query_params
            query[key] = value
        end

        response = get("$base_url$endpoint", query = query)

        if response.status != 200
            error(response.status)
        end

        jr = json(response)
        users = MeetupUser[]

        for r=jr["results"]
            push!(users, MeetupUser(r["id"], r["name"], r["link"]))
        end

        return users
    end

    function get_events(meetup::Meetup, month::Int, year::Int)
    end

    function get_groups(user::MeetupUser)
    end
end

Molcajete.show_calendar("Julia-Users-Group", 11, 2016)

