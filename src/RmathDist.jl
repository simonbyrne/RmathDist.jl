module RmathDist

using Distributions

import Distributions: pdf, logpdf, cdf, logcdf, ccdf, logccdf,
    quantile, cquantile, invlogcdf, invlogccdf, rand

export 
    RBeta,
    RBinomial,
    RCauchy,
    RChisq,
    RFDist,
    RGamma,
    RGeometric,
    RHyperGeometric,
    RLogistic,
    RLogNormal,
    RNegativeBinomial,
    RNoncentralBeta,
    RNoncentralChisq,
    RNoncentralF,
    RNoncentralT,
    RNormal,
    RPoisson,
    RTDist,
    RUniform,
    RWeibull


const Rmath = :libRmath

macro _jl_dist_1p(T, b)
    dd = Expr(:quote, string("d", b))     # C name for pdf
    pp = Expr(:quote, string("p", b))     # C name for cdf
    qq = Expr(:quote, string("q", b))     # C name for quantile
    rr = Expr(:quote, string("r", b))     # C name for random sampler
    Ty = eval(T)
    dc = Ty <: DiscreteDistribution
    pn = Ty.names                       # parameter names
    p  = Expr(:quote, pn[1])
    quote
        global pdf, logpdf, cdf, logcdf, ccdf, logccdf
        global quantile, cquantile, invlogcdf, invlogccdf, rand
        function pdf(d::($T), x::Real)
            ccall(($dd, Rmath), Float64,
                  (Float64, Float64, Int32),
                  x, d.($p), 0)
        end
        function logpdf(d::($T), x::Real)
            ccall(($dd, Rmath), Float64,
                  (Float64, Float64, Int32),
                  x, d.($p), 1)
        end
        function cdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Int32, Int32),
                  q, d.($p), 1, 0)
        end
        function logcdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Int32, Int32),
                  q, d.($p), 1, 1)
        end
        function ccdf(d::($T), q::Real)
            ccall(($pp, Rmath),
                  Float64, (Float64, Float64, Int32, Int32),
                  q, d.($p), 0, 0)
        end
        function logccdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64, (Float64, Float64, Int32, Int32),
                  q, d.($p), 0, 1)
        end
        function quantile(d::($T), p::Real)
            ccall(($qq, Rmath), Float64, (Float64, Float64, Int32, Int32),
                  p, d.($p), 1, 0)
        end
        function cquantile(d::($T), p::Real)
            ccall(($qq, Rmath), Float64, (Float64, Float64, Int32, Int32),
                  p, d.($p), 0, 0)
        end
        function invlogcdf(d::($T), lp::Real)
            ccall(($qq, Rmath), Float64, (Float64, Float64, Int32, Int32),
                  lp, d.($p), 1, 1)
        end
        function invlogccdf(d::($T), lp::Real)
            ccall(($qq, Rmath), Float64, (Float64, Float64, Int32, Int32),
                  lp, d.($p), 0, 1)
        end
        if $dc
            function rand(d::($T))
                int(ccall(($rr, Rmath), Float64, (Float64,), d.($p)))
            end
        else
            function rand(d::($T))
                ccall(($rr, Rmath), Float64, (Float64,), d.($p))
            end
        end
    end
end

macro _jl_dist_2p(T, b)
    dd = Expr(:quote, string("d",b))     # C name for pdf
    pp = Expr(:quote, string("p",b))     # C name for cdf
    qq = Expr(:quote, string("q",b))     # C name for quantile
    rr = Expr(:quote, string("r",b))     # C name for random sampler
    Ty = eval(T)
    dc = Ty <: DiscreteDistribution
    pn = Ty.names                       # parameter names
    p1 = Expr(:quote, pn[1])
    p2 = Expr(:quote, pn[2])
    if string(b) == "norm"              # normal dist has unusual names
        dd = Expr(:quote, :dnorm4)
        pp = Expr(:quote, :pnorm5)
        qq = Expr(:quote, :qnorm5)
    end
    quote
        global pdf, logpdf, cdf, logcdf, ccdf, logccdf
        global quantile, cquantile, invlogcdf, invlogccdf, rand
        function pdf(d::($T), x::Real)
            ccall(($dd, Rmath),
                  Float64, (Float64, Float64, Float64, Int32),
                  x, d.($p1), d.($p2), 0)
        end
        function logpdf(d::($T), x::Real)
            ccall(($dd, Rmath),
                  Float64, (Float64, Float64, Float64, Int32),
                  x, d.($p1), d.($p2), 1)
        end
        function cdf(d::($T), q::Real)
            ccall(($pp, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), 1, 0)
        end
        function logcdf(d::($T), q::Real)
            ccall(($pp, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), 1, 1)
        end
        function ccdf(d::($T), q::Real)
            ccall(($pp, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), 0, 0)
        end
        function logccdf(d::($T), q::Real)
            ccall(($pp, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), 0, 1)
        end
        function quantile(d::($T), p::Real)
            ccall(($qq, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  p, d.($p1), d.($p2), 1, 0)
        end
        function cquantile(d::($T), p::Real)
            ccall(($qq, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  p, d.($p1), d.($p2), 0, 0)
        end
        function invlogcdf(d::($T), lp::Real)
            ccall(($qq, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  lp, d.($p1), d.($p2), 1, 1)
        end
        function invlogccdf(d::($T), lp::Real)
            ccall(($qq, Rmath),
                  Float64, (Float64, Float64, Float64, Int32, Int32),
                  lp, d.($p1), d.($p2), 0, 1)
        end
        if $dc
            function rand(d::($T))
                int(ccall(($rr, Rmath), Float64,
                          (Float64,Float64), d.($p1), d.($p2)))
            end
        else
            function rand(d::($T))
                ccall(($rr, Rmath), Float64,
                      (Float64,Float64), d.($p1), d.($p2))
            end
        end
    end
end

macro _jl_dist_3p(T, b)
    dd = Expr(:quote, string("d", b))     # C name for pdf
    pp = Expr(:quote, string("p", b))     # C name for cdf
    qq = Expr(:quote, string("q", b))     # C name for quantile
    rr = Expr(:quote, string("r", b))     # C name for random sampler
    Ty = eval(T)
    dc = Ty <: DiscreteDistribution
    pn = Ty.names                       # parameter names
    p1 = Expr(:quote, pn[1])
    p2 = Expr(:quote, pn[2])
    p3 = Expr(:quote, pn[3])
    quote
        global pdf, logpdf, cdf, logcdf, ccdf, logccdf
        global quantile, cquantile, invlogcdf, invlogccdf, rand
        function pdf(d::($T), x::Real)
            ccall(($dd, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32),
                  x, d.($p1), d.($p2), d.($p3), 0)
        end
        function logpdf(d::($T), x::Real)
            ccall(($dd, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32),
                  x, d.($p1), d.($p2), d.($p3), 1)
        end
        function cdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), d.($p3), 1, 0)
        end
        function logcdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), d.($p3), 1, 1)
        end
        function ccdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), d.($p3), 0, 0)
        end
        function logccdf(d::($T), q::Real)
            ccall(($pp, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  q, d.($p1), d.($p2), d.($p3), 0, 1)
        end
        function quantile(d::($T), p::Real)
            ccall(($qq, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  p, d.($p1), d.($p2), d.($p3), 1, 0)
        end
        function cquantile(d::($T), p::Real)
            ccall(($qq, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  p, d.($p1), d.($p2), d.($p3), 0, 0)
        end
        function invlogcdf(d::($T), lp::Real)
            ccall(($qq, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  lp, d.($p1), d.($p2), d.($p3), 1, 1)
        end
        function invlogccdf(d::($T), lp::Real)
            ccall(($qq, Rmath), Float64,
                  (Float64, Float64, Float64, Float64, Int32, Int32),
                  lp, d.($p1), d.($p2), d.($p3), 0, 1)
        end
        if $dc
            function rand(d::($T))
                int(ccall(($rr, Rmath), Float64,
                          (Float64,Float64,Float64), d.($p1), d.($p2), d.($p3)))
            end
        else
            function rand(d::($T))
                ccall(($rr, Rmath), Float64,
                      (Float64,Float64,Float64), d.($p1), d.($p2), d.($p3))
            end
        end
    end
end


include(joinpath("univariate", "beta.jl"))
include(joinpath("univariate", "binomial.jl"))
include(joinpath("univariate", "cauchy.jl"))
include(joinpath("univariate", "chisq.jl"))
include(joinpath("univariate", "fdist.jl"))
include(joinpath("univariate", "gamma.jl"))
include(joinpath("univariate", "geometric.jl"))
include(joinpath("univariate", "hypergeometric.jl"))
include(joinpath("univariate", "logistic.jl"))
include(joinpath("univariate", "lognormal.jl"))
include(joinpath("univariate", "negativebinomial.jl"))
include(joinpath("univariate", "noncentralbeta.jl"))
include(joinpath("univariate", "noncentralchisq.jl"))
include(joinpath("univariate", "noncentralf.jl"))
include(joinpath("univariate", "noncentralt.jl"))
include(joinpath("univariate", "normal.jl"))
include(joinpath("univariate", "poisson.jl"))
include(joinpath("univariate", "tdist.jl"))
include(joinpath("univariate", "uniform.jl"))
include(joinpath("univariate", "weibull.jl"))


end # module
