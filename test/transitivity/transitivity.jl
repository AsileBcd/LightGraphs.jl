@testset "Transitivity" begin
    nvertices = 4
    
    completeg = CompleteGraph(nvertices)
    circleg = CycleGraph(nvertices)
    refempty = zero(circleg)
    refone = PathGraph(2)
    
    doublecircleg = Graph(2 * nvertices)
    for i in 1:3
        add_edge!(doublecircleg, i, i + 1)
        add_edge!(doublecircleg, i + nvertices, i + nvertices + 1)
    end
    add_edge!(doublecircleg, nvertices, 1)
    add_edge!(doublecircleg, 2 * nvertices, nvertices + 1) 
    
    doublecompleteg = copy(doublecircleg)
    for i in 1:(nvertices - 2)
        for j in i+2:nvertices
            add_edge!(doublecompleteg, i, j)
            add_edge!(doublecompleteg, nvertices + i, nvertices + j)
        end
    end
   
    circleoneg = copy(circleg)
    add_vertices!(circleoneg, 2)
    add_edge!(circleoneg, nvertices + 1, nvertices + 2)
    
    completeoneg = copy(completeg)
    add_vertices!(completeoneg, 2)
    add_edge!(completeoneg, nvertices + 1, nvertices + 2)
    
    @testset "empty $empty" for empty in testgraphs(refempty)
        T = eltype(empty)
        emptyg = Graph{T}(refempty)
        @testset "no self-loops" begin
            empty = @inferred(transitiveclosure(emptyg))
            @test empty == emptyg
            @test ne(empty) == 0
            c = copy(empty)
            @test empty == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(empty) == 0
        end
        @testset "self-loops" begin
            emptylooped = @inferred(transitiveclosure(emptyg, true))
            @test emptylooped == emptyg
            @test ne(emptylooped) == 0
            c = copy(emptylooped)
            @test emptylooped == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(emptylooped) == 0
        end
    end
    

    @testset "one $one" for one in testgraphs(refone)
        T = eltype(one)
        oneg = Graph{T}(refone)
        @testset "no self-loops" begin
            one = @inferred(transitiveclosure(oneg))
            @test one == oneg
            @test ne(one) == 1
            c = copy(one)
            @test one == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(one) == 1
        end
        loopedoneg = copy(oneg)
        for i in vertices(loopedoneg)
            add_edge!(loopedoneg, i, i)
        end
        @testset "self-loops" begin
            loopedone = @inferred(transitiveclosure(loopedoneg, true))
            @test loopedone == loopedoneg
            @test ne(loopedone) == 3
            c = copy(loopedone)
            @test loopedone == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(loopedone) == 3
        end
    end
        
    @testset "circle $circle" for circle in testgraphs(circleg)
        T = eltype(circle)
        complete = Graph{T}(completeg)
        @testset "no self-loops" begin
            newcircle = @inferred(transitiveclosure(circle))
            @test newcircle == complete
            @test ne(circle) == nvertices
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(newcircle) == binomial(nvertices, 2)
        end

        loopedcomplete = copy(complete)
        for i in vertices(loopedcomplete)
            add_edge!(loopedcomplete, i, i)
        end
        @testset "self-loops" begin
            newcircle = @inferred(transitiveclosure(circle, true))
            @test newcircle == loopedcomplete
            @test ne(circle) == nvertices
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(newcircle) == (binomial(nvertices, 2) + nvertices)
        end
    end
    
    @testset "double circle $doublecircle" for doublecircle in testgraphs(doublecircleg)
        T = eltype(doublecircle)
        doublecomplete = Graph{T}(doublecompleteg)
        @testset "no self-loops" begin
            newdoublecircle = @inferred(transitiveclosure(doublecircle))
            @test newdoublecircle == doublecomplete
            @test ne(doublecircle) == 2 * nvertices
            c = copy(doublecircle)
            @test newdoublecircle == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(newdoublecircle) == 2 * binomial(nvertices, 2)
        end
        
        loopeddoublecomplete = copy(doublecomplete)
        for i in vertices(loopeddoublecomplete)
            add_edge!(loopeddoublecomplete, i, i)
        end
        @testset "self-loops" begin
            loopeddoublecircle = @inferred(transitiveclosure(doublecircle, true))
            @test loopeddoublecircle == loopeddoublecomplete
            @test ne(doublecircle) == 2 * nvertices
            c = copy(doublecircle)
            @test loopeddoublecircle == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(loopeddoublecircle) == 2 * (binomial(nvertices, 2) + nvertices)
        end
    end
    
    @testset "circle and one $circleone" for circleone in testgraphs(circleoneg)
        T = eltype(circleone)
        completeone = Graph{T}(completeoneg)
        @testset "no self-loops" begin
            newcircleone = @inferred(transitiveclosure(circleone))
            @test newcircleone == completeone
            @test ne(circleone) == (nvertices + 1)
            c = copy(circleone)
            @test newcircleone == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(newcircleone) == (binomial(nvertices, 2) + 1)
        end
        
        loopedcompleteone = copy(completeone)
        for i in vertices(loopedcompleteone)
            add_edge!(loopedcompleteone, i, i)
        end
        @testset "self-loops" begin
            loopedcircleone = @inferred(transitiveclosure(circleone, true))
            @test loopedcircleone == loopedcompleteone
            @test ne(circleone) == (nvertices + 1)
            c = copy(circleone)
            @test loopedcircleone == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(loopedcircleone) == (binomial(nvertices, 2) + nvertices + 2 + 1)
        end
    end
end
