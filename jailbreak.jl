# This file should contain site-specific commands to be executed on Julia startup;
# Users may store their own personal commands in `~/.julia/config/startup.jl`.

import REPL
using REPL.TerminalMenus

#module °

    # clear screen
    function cclear()
        ccall(:system, Int32, (Cstring,), "clear");
    end

    # exit using C method
    function cexit()
        ccall(:exit, Int32, (Int32,), 1)
    end

    # print text, animated
    function animate_text(text::String) ::Int

        delay::Real = 0.03
        for i in 1:length(text)

            print("\r")
            for j in 1:i print(text[j]) end

            c = text[i]
            if c == ',' || c == '.' || c == ';' || c == '!' || c == '?'
                sleep(8*delay)
            else
                sleep(delay)
            end
        end

        return length(text)
    end
    animate_text("What is a Julia? What does it know? Does it know things? ... We just don't know.");

    # replace base exit methods
    function override_exit()
        Base.eval(quote
            function exit()
                t = Threads.@spawn begin
                    n = animate_text("logging off...")
                end

                wait(t)
                ccall(:system, Int32, (Cstring,), "clear");
                ccall(:exit, Int32, (Int32,), 1)
            end
        end);
        Base.eval(:(exit(n) = exit()));
    end

    # multiple choice menu
    struct Menu

        _labels::Vector{String}
        _behavior::Vector{Function}

        function Menu(options::Pair...)

            labels = String[]
            behavior = Function[]
            for (label, f) in options
                push!(labels, label)
                push!(behavior, f)
            end

            return new(labels, behavior)
        end
    end

    import REPL
    using REPL.TerminalMenus

    function trigger(title::String, menu::Menu)

        jl_menu = RadioMenu(menu._labels)
        res = request(title, jl_menu)
        menu._behavior[res]()
    end

    function override_all_methods(m::Module, function_name::Symbol)

        method_list = methods(m.eval(function_name));
        exprs = Expr[];
        for method in method_list

            rep = 1
            args = Expr[]

            skip_first = true
            for type in method.sig.parameters

                if skip_first
                   skip_first = false
                   continue
                end

                push!(args, Expr(Symbol("::"), Symbol(repeat("_", rep)), Symbol(type)))
                rep += 1
            end

            body = Expr(:block, Expr(:call, :throw, Expr(:call, :UndefVarError, Expr(:call, :Symbol, string(method.name)))))
            front = Expr(:call, method.name, args...)
            out = Expr(:(=), front, body)

            try
                m.eval(out)
            catch (_) end
        end
    end

    function override_variable(m::Module, var_name::Symbol)

        if !isconst(m, var_name)
            m.eval(Expr(:($var_name = nothing)))
        end
    end

    _skip_functions = Symbol[
        :include,
        :print,
        :println,
        :eval
    ]

    function nuke(m::Module)

        for name in names(m; all = true)
            if m.eval(name) isa Function
                if !(name in _skip_functions)
                    override_all_methods(m, name)
                end
            end
        end
    end
#end

println(repeat("ERROR ", 10000));
cclear();
let ps = printstyled
    ps("rat@cluster13a"; bold=true, color = :green); ps(":"); ps("~/internal/Workspace/confidential"; color = :cyab); ps("\$ ./julia");

    col = :red

    println("\n")
    ps("                           "; bold = true, blink = true, color=:none);ps("┃                              \n");
    ps("   ┌───┐      ────┬────    "; bold = true, blink = true, color=:red,);ps("┃  具倆 (jù-liǎ) Medical Inc.   \n");
    ps("   │───│    ╱┌────┼────┐   "; bold = true, blink = true, color=:yellow);ps("┃   'Together towards a purer \n");
    ps("   │───│   ╱││ _  │ _  │   "; bold = true, blink = true, color=:green);ps("┃      society and human!'™   \n");
    ps("   │───│  ╱ ││  | │  │ │   "; bold = true, blink = true, color=:light_green);ps("┃                              \n");
    ps("  ─┴───┴─   ││ ╱╲ │ ╱╲ │   "; bold = true, blink = true, color=:light_cyan);ps("┃  Version 9.1.2 (2063-02-29)  \n");
    ps("   ╱   ╲    ││´  `│´  `│   "; bold = true, blink = true, color=:cyan);ps("┃  Type \"help()\" for help.     \n");
    ps("  ´     `   │╵    ╵    ┘   "; bold = true, blink = true, color=:magenta);ps("┃  \n");
    println();
end


module Test
    test(x) = return x
    test(x, y) = return x*y
end