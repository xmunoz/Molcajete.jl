#module Molcajete

    print("Loading Molcajete module\n");

    function initialise_test()
        print("Initialising module Molcajete\n");
    end
    __init__ = initialise_test();

    import Requests: get, json
    import DataStructures: counter, OrderedDict
    using PlotlyJS

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
        events::OrderedDict{}
    end

    type MeetupUser
        id::Int
        name
        link
        meetups::Array{Meetup, 1}
    end

    function show_calendar(meetup_name::String, start_date::Date, end_date::Date; num_meetups = 10)
        ranked_meetups = find_common_meetups(meetup_name, num_meetups)
        meetups = get_events(ranked_meetups, start_date, end_date)
        plot_histogram(meetups)
    end

    function plot_histogram(meetups)
        println("Plotting events.")
        # plotly raises an exception if data is simply initialized with []
        data = PlotlyJS.GenericTrace[]
        for (meetup, count) in meetups
            y = collect(values(meetup.events))
            x = collect(keys(meetup.events))
            name = meetup.name
            if y != zeros(length(y))
                tr = bar(;x=x, y=y, name=name)
                push!(data, tr)
            end
        end
        layout = Layout(;barmode="stack")
        display(plot(data, layout))
        readline()
    end

    function find_common_meetups(name::String, n::Int)
        meetup = get_meetup(name)
        members = get_meetup_members(meetup)
        for mem=members
            get_meetups_of_member(mem)
        end
        println()
        return find_top_meetups(members, meetup.city, meetup.country, n)
    end

    function find_top_meetups(members::Array{MeetupUser}, city, country, top::Int)
        c = counter(Int)
        meetupdict = Dict()
        for mem=members
            for meet=mem.meetups
                if meet.city == city && meet.country == country
                    push!(c, meet.id)
                end
                # this sucks, i hate julia
                if !haskey(meetupdict, meet.id)
                    meetupdict[meet.id] = meet
                end
            end
        end

        # no most common method for counters, this sucks
        # also, overloading == and isequal still doesnt enable counter to validly compare meetups
        sorted = select!(collect(c), 1:length(c), by=kv->kv[2], rev=true)

        results = []
        for (i,count) in sorted
            push!(results, (meetupdict[i], count))
        end

        # number 1 will basically always be the input meetup, exclude it
        return results[2:top+1]
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
        print(".")
        for res in result
           push!(member.meetups, Meetup(res["id"], res["name"], res["city"], res["country"], OrderedDict()))
        end
    end

    function get_meetup(name::String)
        println("Fetching info for $name meetup.")
        r = perform_request("$base_url$name", default_query_params)
        Meetup(r["id"], r["urlname"], r["city"], r["country"], OrderedDict())
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
            push!(users, MeetupUser(r["id"], r["name"], r["link"], Meetup[]))
        end

        return users
    end

    function get_events(meetups, start_date::Date, end_date::Date)
        println("Fetching events in date range.")
        endpoint = "2/events"

        query = Dict()
        starttime = Int(Dates.datetime2unix(Dates.DateTime(start_date))) * 1000
        endtime = Int(Dates.datetime2unix(Dates.DateTime(end_date))) * 1000
        query["time"] = "$starttime,$endtime"
        for (key, value) in default_query_params
            query[key] = value
        end

        for (meetup,count)=meetups
            meetup.events = OrderedDict{Date, Int64}(k => 0 for k in start_date:end_date)
            query["group_id"] = meetup.id
            res = perform_request("$base_url$endpoint", query)["results"]
            for r=res
               dt = Dates.unix2datetime(r["time"]/1000)
               meetup.events[Date(Dates.yearmonthday(dt)...)] += count
            end
        end
        return meetups
    end

    function perform_request(url::String, params::Dict)
        response = get(url, query = params)

        if response.status != 200
            println(response.status)
            error(json(response)["errors"][1]["message"])
        end

        json(response)
    end
#end
