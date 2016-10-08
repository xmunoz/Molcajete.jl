__precompile__()

module Molcajete

    import Requests: get, post, put, delete, options, json

    global base_url = "https://api.meetup.com/"

    if !haskey(ENV, "MEETUP_API_TOKEN")
        error("MEETUP_API_TOKEN environment variable is required.")
    end

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

    function find_common_meetups(name::String)
        meetup = get_meetup(name)
        members = get_meetup_members(meetup)
        @sync for mem=members
            @async begin
                get_meetups_of_member(mem)
            end
        end
        return
    end

    function get_meetups_of_member(member::MeetupUser)
        name = member.name
        endpoint = "2/groups"

        query = Dict()
        query["member_id"] = member.id
        for (key, value) in default_query_params
            query[key] = value
        end

        result = perform_request("$base_url$endpoint", query)["results"]
        println(member.name)
        member.meetups = Meetup[]
        for res in result
           push!(member.meetups, Meetup(res["id"], res["name"], res["city"], res["country"]))
        end
    end

    function get_meetup(name::String)
        println("Fetching info for $name meetup.")
        r = perform_request("$base_url$name", default_query_params)
        Meetup(r["id"], r["urlname"], r["city"], r["country"])
    end

    function get_meetup_members(meetup::Meetup)
        println("Fetching meetup members.")
        endpoint = "2/members"

        query = Dict()
        query["group_urlname"] = meetup.name
        for (key, value) in default_query_params
            query[key] = value
        end

        response = perform_request("$base_url$endpoint", query)

        users = MeetupUser[]

        for r=response["results"]
            push!(users, MeetupUser(r["id"], r["name"], r["link"]))
        end

        return users
    end

    function get_events(meetup::Meetup, month::Int, year::Int)
    end

    function perform_request(url::String, params::Dict)
        response = get(url, query = params)

        if response.status != 200
            error(response.status)
        end

        json(response)
    end
end

Molcajete.show_calendar("Julia-Users-Group", 11, 2016)

