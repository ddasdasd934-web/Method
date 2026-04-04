-- Detach and initialize a Lycoris instance.
local Lycoris = {
    queued = false,
    silent = false,
    dpscanning = false,
    norpc = false
}

---@module Utility.Logger
local Logger = require("Utility/Logger")

---@module Game.Hooking
local Hooking = require("Game/Hooking")

---@module Menu
local Menu = require("Menu")

---@module Features
local Features = require("Features")

---@module Utility.ControlModule
local ControlModule = require("Utility/ControlModule")

---@module Game.InputClient
local InputClient = require("Game/InputClient")

---@module Game.PlayerScanning
local PlayerScanning = require("Game/PlayerScanning")

---@module Game.Timings.SaveManager
local SaveManager = require("Game/Timings/SaveManager")

---@module Features.Combat.StateListener
local StateListener = require("Features/Combat/StateListener")

---@module Utility.PersistentData
local PersistentData = require("Utility/PersistentData")

---@module Game.KeyHandling
local KeyHandling = require("Game/KeyHandling")

---@module Game.QueuedBlocking
local QueuedBlocking = require("Game/QueuedBlocking")

---@module Utility.Maid
local Maid = require("Utility/Maid")

---@module Utility.Signal
local Signal = require("Utility/Signal")

---@module Game.Timings.ModuleManager
local ModuleManager = require("Game/Timings/ModuleManager")

---@module Utility.CoreGuiManager
local CoreGuiManager = require("Utility/CoreGuiManager")

---@module Game.ServerHop
local ServerHop = require("Game/ServerHop")

---@module Game.Wipe
local Wipe = require("Game/Wipe")

---@module Game.UpdateNotifier
local UpdateNotifier = require("Game/UpdateNotifier")

---@module Features.Automation.EchoFarm
local EchoFarm = require("Features/Automation/EchoFarm")

---@module Features.Automation.AuthorityFarm
local AuthorityFarm = require("Features/Automation/AuthorityFarm")

---@module Features.Automation.AutoDepths
local AutoDepths = require("Features/Automation/AutoDepths")

-- Lycoris maid.
local lycorisMaid = Maid.new()

-- Constants.
local LOBBY_PLACE_ID = 4111023553
local DEPTHS_PLACE_ID = 5735553160
local CHIME_LOBBY_PLACE_ID = 12559711136

local getWebhookUrl = function(...)
    return (function(...)
        local X = {"\100\065\119\065\100\089\119\079\081\076\119\084\117\098\049\102",
                   "\102\051\049\051\100\080\119\077\102\080\116\054\100\090\057\072\075\103\061\061",
                   "\104\055\061\061",
                   "\073\069\066\118\100\054\048\048\079\074\116\107\079\080\055\080\075\076\084\061",
                   "\051\098\066\116\112\074\048\076\075\052\061\061", "", "\051\098\066\120\047\081\053\061",
                   "\086\043\087\111\052\106\074\065\053\109\065\116\043\069\079\104\121\073\106\106\075\108\070\088\069\121\100\107\057\074\073\106\081\101\119\111\109\118\098\108\113\077\086\102\102\052\081\049\108\084\110\082\053\120\102\107\085\101\113\082\082\082\088\075\054\089\089\112\080\117\067\100\077\084\102\049\088\050\111\043\110\109\101\083\087\109\069\047\107\120\083\116\057\084\109\080\075\083\051\080\078\087\106\100\056\087\049\088\054\049\077\073\100\118\070\086\098\100\087\075\110\099\121\057\119\071\119\079\116\116\117\119\074\116\066\078\065\085\065\056\071\080\098\122\084\083\072\068\107\119\107\116\098\051\108\070\055\079\122\080\074\055\061\061",
                   "\051\098\066\088\109\082\061\061",
                   "\117\069\049\057\112\081\049\057\109\051\048\119\109\074\043\076",
                   "\073\105\066\110\073\081\098\056\047\051\118\061", "\112\105\049\110",
                   "\104\056\055\076\047\113\084\116\104\055\061\061",
                   "\073\105\066\106\073\065\050\116\112\074\117\061", "\112\068\118\061",
                   "\117\080\048\072\121\081\107\088", "\109\088\076\057\047\103\061\061",
                   "\048\077\053\043\104\051\119\057\079\089\047\084\121\077\066\068\075\079\077\061",
                   "\109\069\119\119\117\055\061\061",
                   "\079\077\116\114\090\051\049\087\109\079\100\120\049\077\107\114\090\052\061\061",
                   "\109\069\066\110\109\069\089\057",
                   "\100\106\047\116\103\081\055\107\117\077\073\089\109\088\084\080\079\055\061\061",
                   "\117\074\049\099\112\080\047\076", "\112\081\089\057\121\052\061\061",
                   "\048\074\107\077\112\074\050\106",
                   "\049\105\089\099\117\105\049\072\118\077\048\076\073\105\049\054\073\105\049\122\118\103\061\061",
                   "\117\105\100\119\112\105\082\061", "\047\051\050\072\112\080\118\061",
                   "\117\074\089\110\047\105\066\099", "\073\089\100\054\102\105\049\089\090\079\073\054",
                   "\121\076\118\053\075\068\047\082\103\098\049\087\049\080\073\047",
                   "\051\098\066\099\047\051\048\119\073\105\089\056\112\105\090\061",
                   "\047\074\043\097\112\080\118\061",
                   "\104\081\066\068\079\065\052\082\090\105\076\097\075\105\089\110",
                   "\100\105\076\119\073\065\047\100\100\105\084\107\121\105\066\043\047\069\117\061",
                   "\073\105\089\056\112\105\090\061",
                   "\049\069\076\051\090\098\084\069\104\081\100\081\117\090\050\116\121\068\103\061",
                   "\047\069\098\119\073\105\100\084", "\047\080\100\098\109\055\061\061",
                   "\048\081\048\118\047\049\049\057\090\069\066\049\104\077\099\053\090\055\061\061",
                   "\112\080\047\109\112\076\089\050\103\090\118\082\067\057\099\118\075\103\061\061",
                   "\103\080\087\069\075\090\119\050\075\081\098\086\073\057\053\061",
                   "\073\081\107\082\109\081\100\111", "\112\068\077\061"}
        for t, E in ipairs({{-796217 + 796218, -607815 - (-607859)}, {-216231 + 216232, -295496 - (-295529)},
                            {-801913 + 801947, 30093 - 30049}}) do
            while E[392429 - 392428] < E[720824 - 720822] do
                X[E[189351 - 189350]], X[E[952960 - 952958]], E[-676980 - (-676981)], E[-869177 - (-869179)] =
                    X[E[-415405 + 415407]], X[E[-153317 + 153318]], E[843578 + -843577] + (279402 - 279401),
                    E[263530 - 263528] - (-345770 - (-345771))
            end
        end
        local function t(t)
            return X[t - (169367 - 160933)]
        end
        do
            local t = string.sub
            local E = {
                V = 132083 - 132068,
                h = -398892 + 398906,
                p = -759864 + 759891,
                ["\056"] = -118018 - (-118052),
                l = 747891 - 747831,
                ["\057"] = 744183 + -744131,
                ["\047"] = -327274 + 327299,
                F = -130916 + 130979,
                t = -279721 + 279762,
                q = -978750 + 978752,
                a = 762727 - 762680,
                c = -118948 + 118993,
                L = 54498 + -54461,
                X = 174156 - 174117,
                d = -806188 - (-806201),
                b = 906097 - 906044,
                ["\049"] = -87843 + 87864,
                ["\054"] = 222055 + -222020,
                U = 635091 - 635060,
                Q = 535729 + -535707,
                B = 300774 - 300713,
                x = 424665 - 424621,
                Z = 545157 - 545137,
                T = -253736 + 253776,
                f = 626611 + -626593,
                P = -262385 - (-262440),
                N = 584754 + -584695,
                u = -343119 - (-343147),
                H = -783416 + 783466,
                ["\053"] = 477359 + -477303,
                v = 669493 + -669485,
                W = -659699 - (-659700),
                Y = 184235 - 184230,
                ["\051"] = 1047191 - 1047168,
                E = 21911 - 21857,
                k = 519849 - 519792,
                ["\048"] = -295145 + 295162,
                r = 954686 + -954676,
                w = -314633 - (-314666),
                i = 865467 + -865461,
                ["\043"] = -785080 + 785129,
                n = 361899 + -361853,
                s = 12704 + -12693,
                C = 600051 + -600039,
                M = -276581 - (-276585),
                m = 523440 + -523416,
                o = 272360 + -272317,
                A = -67355 - (-67362),
                e = -414915 - (-414957),
                D = -63138 + 63141,
                J = 174885 + -174847,
                ["\055"] = -553873 - (-553905),
                g = 256488 + -256472,
                ["\050"] = 949446 - 949437,
                z = -20733 - (-20769),
                S = -166821 + 166879,
                j = 440302 + -440251,
                R = 673653 + -673605,
                y = -1019686 - (-1019712),
                ["\052"] = 522416 + -522416,
                I = -84131 + 84160,
                K = -169253 + 169283,
                G = -477743 + 477805,
                O = -118628 + 118647
            }
            local g = string.len
            local r = type
            local S = table.insert
            local V = string.char
            local b = X
            local M = math.floor
            local O = table.concat
            for X = -245991 - (-245992), #b, -820665 + 820666 do
                local N = b[X]
                if r(N) == "\115\116\114\105\110\103" then
                    local r = g(N)
                    local h = {}
                    local v = -436462 + 436463
                    local I = 731895 + -731895
                    local u = -758199 - (-758199)
                    while v <= r do
                        local X = t(N, v, v)
                        local g = E[X]
                        if g then
                            I = I + g * (371500 + -371436) ^ ((-188646 + 188649) - u)
                            u = u + (796729 + -796728)
                            if u == -716274 - (-716278) then
                                u = -231911 + 231911
                                local X = M(I / (63202 + 2334))
                                local t = M((I % (-859645 - (-925181))) / (23329 - 23073))
                                local E = I % (445038 - 444782)
                                S(h, V(X, t, E))
                                I = 287401 + -287401
                            end
                        elseif X == "\061" then
                            S(h, V(M(I / (-137636 + 203172))))
                            if v >= r or t(N, v + (351852 - 351851), v + (-538737 + 538738)) ~= "\061" then
                                S(h, V(M((I % (-45409 + 110945)) / (-721142 - (-721398)))))
                            end
                            break
                        end
                        v = v + (-363690 - (-363691))
                    end
                    b[X] = O(h)
                end
            end
        end
        return (function(X, g, r, S, V, b, M, N, K, u, s, E, a, v, q, G, h, J, o, I, O)
            G, J, N, s, O, q, o, I, h, u, E, v, K, a = function(X, t)
                local g = I(t)
                local r = function(r, S, V, b)
                    return E(X, {r, S, V, b}, t, g)
                end
                return r
            end, function(X, t)
                local g = I(t)
                local r = function()
                    return E(X, {}, t, g)
                end
                return r
            end, {}, function(X)
                N[X] = N[X] - (793337 + -793336)
                if N[X] == 666869 + -666869 then
                    N[X], O[X] = nil, nil
                end
            end, {}, function(X, t)
                local g = I(t)
                local r = function(r, S, V, b, M)
                    return E(X, {r, S, V, b, M}, t, g)
                end
                return r
            end, function(X, t)
                local g = I(t)
                local r = function(...)
                    return E(X, {...}, t, g)
                end
                return r
            end, function(X)
                for t = 1026112 + -1026111, #X, 937853 + -937852 do
                    N[X[t]] = (513200 + -513199) + N[X[t]]
                end
                if r then
                    local E = r(true)
                    local g = V(E)
                    g[t(-687582 - (-696054))], g[t(115071 - 106595)], g[t(-712604 - (-721078))] = X, u, function()
                        return 4877430 - 908924
                    end
                    return E
                else
                    return S({}, {
                        [t(-188298 - (-196774))] = u,
                        [t(96931 + -88459)] = X,
                        [t(371884 + -363410)] = function()
                            return 129956 + 3838550
                        end
                    })
                end
            end, function()
                v = v + (-665909 + 665910)
                N[v] = 608884 - 608883
                return v
            end, function(X)
                local t, E = 929981 + -929980, X[-632180 + 632181]
                while E do
                    N[E], t = N[E] - (53474 + -53473), t + (-435052 - (-435053))
                    if -951549 - (-951549) == N[E] then
                        N[E], O[E] = nil, nil
                    end
                    E = X[t]
                end
            end, function(E, r, S, V)
                local N, B, D, m, x, o, e, k, U, j, I, Z, y, T, H, p, F, z, Q, w, v, P, u, C, i, R, L, f, M, n, Y, W, c,
                    A
                while E do
                    if E < 8745246 - (-674677) then
                        if E < 105699 + 5439531 then
                            if E < -655476 + 3597043 then
                                if E < 594512 - (-670133) then
                                    if E < 720950 + 233368 then
                                        if E < 372076 + 151310 then
                                            if E < 1084337 - 613811 then
                                                v = t(-541297 - (-549745))
                                                I = 153701 - (-544689)
                                                M = -490223 + 11009073
                                                N = v ^ I
                                                E = M - N
                                                N = E
                                                M = t(165098 - 156645)
                                                E = M / N
                                                M = {E}
                                                E = X[t(437550 + -429107)]
                                            else
                                                I = t(-423917 + 432376)
                                                v = X[I]
                                                I = t(-887358 - (-895804))
                                                N = v[I]
                                                I = O[S[-410156 - (-410157)]]
                                                v = {N(I)}
                                                E = X[t(102775 - 94307)]
                                                M = {g(v)}
                                            end
                                        else
                                            I = -984863 - (-984895)
                                            v = O[S[-137444 + 137447]]
                                            N = v % I
                                            Y = -664501 + 664514
                                            P = -745973 - (-745975)
                                            u = O[S[595190 - 595186]]
                                            W = O[S[187816 - 187814]]
                                            A = O[S[-585906 + 585909]]
                                            y = A - N
                                            E = -308203 - (-822778)
                                            A = -913308 - (-913340)
                                            F = y / A
                                            f = Y - F
                                            Q = P ^ f
                                            n = W / Q
                                            o = u(n)
                                            u = -966974 + 4295934270
                                            Q = 306987 - 306986
                                            I = o % u
                                            o = 901182 - 901180
                                            u = o ^ N
                                            v = I / u
                                            u = O[S[1004031 + -1004027]]
                                            W = v % Q
                                            Q = 4294660630 - (-306666)
                                            n = W * Q
                                            o = u(n)
                                            u = O[S[283753 + -283749]]
                                            n = u(v)
                                            I = o + n
                                            o = -402799 - (-468335)
                                            Y = 660532 - 660276
                                            u = I % o
                                            v = nil
                                            n = I - u
                                            W = -340651 + 406187
                                            o = n / W
                                            W = -777528 + 777784
                                            n = u % W
                                            P = -1030592 + 1030848
                                            I = nil
                                            Q = u - n
                                            W = Q / P
                                            P = 627443 + -627187
                                            u = nil
                                            Q = o % P
                                            f = o - Q
                                            P = f / Y
                                            o = nil
                                            f = {n, W, Q, P}
                                            Q = nil
                                            O[S[938429 + -938428]] = f
                                            P = nil
                                            W = nil
                                            N = nil
                                            n = nil
                                        end
                                    else
                                        if E < -974718 + 2202159 then
                                            f = f + Y
                                            Q = f <= P
                                            y = not F
                                            Q = y and Q
                                            y = f >= P
                                            y = F and y
                                            Q = y or Q
                                            y = 9312509 - 212967
                                            E = Q and y
                                            Q = 120228 + 14625822
                                            E = E or Q
                                        else
                                            E = X[t(809488 - 801017)]
                                            M = {v}
                                        end
                                    end
                                else
                                    if E < 172005 + 1723727 then
                                        if E < -782072 + 2254283 then
                                            E = M and -395820 + 11536768 or 3411911 - (-544433)
                                        else
                                            f = t(-804857 + 813323)
                                            P = X[f]
                                            E = 4043099 - (-117540)
                                            M = P
                                        end
                                    else
                                        if E < -326186 + 2521450 then
                                            I = O[S[-709494 + 709500]]
                                            v = I == N
                                            E = 12622497 - (-798969)
                                            M = v
                                        else
                                            E = f
                                            E = P and 4704816 - 544177 or 2426090 - 557233
                                            M = P
                                        end
                                    end
                                end
                            else
                                if E < 727799 + 3503501 then
                                    if E < 471343 + 3329990 then
                                        if E < -595634 + 4285200 then
                                            if E < 2507519 - (-832890) then
                                                I = 784568 + -784568
                                                N = t(47777 + -39326)
                                                E = X[N]
                                                v = O[S[333554 - 333546]]
                                                N = E(v, I)
                                                E = 9618886 - 541361
                                            else
                                                m = O[v]
                                                E = m and 3883734 - (-611251) or 12609826 - 889276
                                                p = m
                                            end
                                        else
                                            E = true
                                            E = E and 4289826 - (-537969) or 9348734 - 746359
                                        end
                                    else
                                        if E < 668277 + 3349262 then
                                            E = O[S[781688 + -781681]]
                                            E = E and -977982 + 4205216 or 29729 + 9047796
                                        else
                                            Y = -419244 - (-419309)
                                            P = h()
                                            O[P] = M
                                            E = O[W]
                                            f = -659185 - (-659188)
                                            M = E(f, Y)
                                            f = h()
                                            O[f] = M
                                            y = t(-515568 + 524018)
                                            E = -898812 - (-898812)
                                            M = X[y]
                                            Y = E
                                            E = -175205 + 175205
                                            F = E
                                            A = J(-420973 + 721014, {})
                                            y = {M(A)}
                                            E = {g(y)}
                                            y = E
                                            M = -321258 + 321260
                                            E = y[M]
                                            A = E
                                            k = t(-420333 + 428770)
                                            M = t(969790 + -961312)
                                            E = X[M]
                                            B = O[I]
                                            i = X[k]
                                            k = i(A)
                                            i = t(440737 - 432301)
                                            U = B(k, i)
                                            B = {U()}
                                            M = E(g(B))
                                            B = h()
                                            E = -18721 + 6066649
                                            O[B] = M
                                            U = O[f]
                                            M = -766519 - (-766520)
                                            i = U
                                            U = 744375 + -744374
                                            k = U
                                            U = 760376 + -760376
                                            R = k < U
                                            U = M - k
                                        end
                                    end
                                else
                                    if E < 5380243 - 509936 then
                                        if E < 5608034 - 955262 then
                                            H = 753848 - 753847
                                            m = e[H]
                                            E = 729463 + 10991087
                                            p = m
                                        else
                                            N = t(-94736 - (-103203))
                                            M = t(941363 - 932925)
                                            E = X[M]
                                            M = X[N]
                                            N = t(757706 - 749239)
                                            X[N] = E
                                            E = 118564 + 3663695
                                            N = t(-831556 - (-839994))
                                            X[N] = M
                                            N = O[S[122660 + -122659]]
                                            v = N()
                                        end
                                    else
                                        if E < 4506809 - (-923133) then
                                            v = t(440062 - 431597)
                                            I = -531248 + 11038321
                                            N = v ^ I
                                            M = 292777 + 1994909
                                            E = M - N
                                            M = t(-887356 + 895814)
                                            N = E
                                            E = M / N
                                            M = {E}
                                            E = X[t(-122206 - (-130660))]
                                        else
                                            T = s(T)
                                            w = s(w)
                                            L = s(L)
                                            e = nil
                                            E = 420141 + 5627787
                                            C = s(C)
                                            z = s(z)
                                            j = s(j)
                                        end
                                    end
                                end
                            end
                        else
                            if E < -617203 + 8572389 then
                                if E < -536561 + 7790751 then
                                    if E < 627123 + 5509188 then
                                        if E < 6251196 - 204070 then
                                            if E < 5916410 - (-123620) then
                                                c = -803001 + 803003
                                                x = e[c]
                                                c = O[T]
                                                E = 795065 + 10682789
                                                H = x == c
                                                p = H
                                            else
                                                W = not n
                                                I = I + o
                                                v = I <= u
                                                v = W and v
                                                W = I >= u
                                                W = n and W
                                                v = W or v
                                                W = 12724453 - 81763
                                                E = v and W
                                                v = 10836588 - 891708
                                                E = E or v
                                            end
                                        else
                                            w = not R
                                            U = U + k
                                            M = U <= i
                                            M = w and M
                                            w = U >= i
                                            w = R and w
                                            M = w or M
                                            w = 7310399 - 77666
                                            E = M and w
                                            M = 16521049 - 811385
                                            E = E or M
                                        end
                                    else
                                        if E < -126948 + 7282684 then
                                            v = O[S[271018 - 271016]]
                                            I = O[S[-680370 - (-680373)]]
                                            N = v == I
                                            M = N
                                            E = 942077 + 394795
                                        else
                                            C = -538929 + 539184
                                            w = h()
                                            j = 442322 - 442222
                                            H = t(973246 + -964809)
                                            Z = 860859 - 860859
                                            O[w] = U
                                            z = t(-698870 + 707317)
                                            M = X[z]
                                            z = t(292585 + -284133)
                                            E = M[z]
                                            z = -390444 + 390445
                                            M = E(z, j)
                                            j = 872187 + -872187
                                            z = h()
                                            T = 262632 + -262631
                                            O[z] = M
                                            E = O[W]
                                            M = E(j, C)
                                            e = 383276 + -383274
                                            j = h()
                                            O[j] = M
                                            E = O[W]
                                            C = 70947 - 70946
                                            L = O[z]
                                            M = E(C, L)
                                            C = h()
                                            D = -924797 + 934797
                                            O[C] = M
                                            M = O[W]
                                            L = M(T, e)
                                            M = -15392 + 15393
                                            E = L == M
                                            L = h()
                                            M = t(-441722 - (-450158))
                                            O[L] = E
                                            e = t(-302292 - (-310762))
                                            m = X[H]
                                            x = O[W]
                                            c = {x(Z, D)}
                                            H = m(g(c))
                                            m = t(795278 - 786808)
                                            E = t(753719 + -745257)
                                            p = H .. m
                                            T = e .. p
                                            E = A[E]
                                            e = t(-268136 + 276586)
                                            E = E(A, M, T)
                                            T = h()
                                            O[T] = E
                                            M = X[e]
                                            p = G(9313085 - 933437, {W, w, f, I, v, B, L, T, z, C, j, P})
                                            e = {M(p)}
                                            E = {g(e)}
                                            e = E
                                            E = O[L]
                                            E = E and 16606748 - 967742 or 4405159 - 920381
                                        end
                                    end
                                else
                                    if E < 6657006 - (-826490) then
                                        if E < 7224415 - (-236007) then
                                            W = t(19551 - 11104)
                                            n = M
                                            Q = t(-450851 - (-459310))
                                            M = X[W]
                                            W = t(-763956 - (-772408))
                                            E = M[W]
                                            W = h()
                                            O[W] = E
                                            M = X[Q]
                                            Q = t(877819 + -869375)
                                            E = M[Q]
                                            f = E
                                            Q = E
                                            F = t(-1034933 - (-1043392))
                                            Y = X[F]
                                            P = Y
                                            E = Y and 11819657 - 940861 or 2910905 - 710262
                                        else
                                            E = 12547040 - 925309
                                        end
                                    else
                                        if E < 8597793 - 934461 then
                                            E = true
                                            E = E and 656500 + 10114773 or 8862639 - 358059
                                        else
                                            B = -725238 + 725239
                                            R = #y
                                            A = u(B, R)
                                            B = n(y, A)
                                            j = 554610 - 554609
                                            A = nil
                                            R = O[F]
                                            z = B - j
                                            w = W(z)
                                            R[B] = w
                                            w = #y
                                            z = 261992 + -261992
                                            B = nil
                                            R = w == z
                                            E = R and 14036173 - (-1012479) or 8215515 - 472815
                                        end
                                    end
                                end
                            else
                                if E < 629620 + 8111915 then
                                    if E < 7406564 - (-1013183) then
                                        if E < 451310 + 7853727 then
                                            E = 866235 + 6876465
                                        else
                                            u = 195686 + -195685
                                            o = -851706 + 851708
                                            v = O[S[406446 - 406445]]
                                            I = v(u, o)
                                            v = -966461 - (-966462)
                                            N = I == v
                                            E = N and 849081 - (-487791) or 7000501 - 561905
                                            M = N
                                        end
                                    else
                                        if E < 614387 + 7951702 then
                                            M = {}
                                            E = X[t(-578098 + 586555)]
                                        else
                                            E = X[t(-439790 + 448235)]
                                            M = {}
                                        end
                                    end
                                else
                                    if E < 9071028 - (-14816) then
                                        if E < 8610988 - (-446894) then
                                            v = O[S[602677 - 602675]]
                                            I = -224423 + 224484
                                            N = v * I
                                            v = 18941383938955 - 118436
                                            M = N + v
                                            N = -746743 + 35184372835575
                                            E = M % N
                                            O[S[456368 - 456366]] = E
                                            E = 897980 + 14032908
                                        else
                                            E = {}
                                            I = O[S[176494 - 176485]]
                                            v = 113445 - 113444
                                            N = E
                                            u = I
                                            I = -784824 + 784825
                                            E = -105763 + 6152667
                                            o = I
                                            I = -181542 - (-181542)
                                            n = o < I
                                            I = v - o
                                        end
                                    else
                                        if E < 535281 + 8722552 then
                                            Q = f
                                            k = t(-881787 + 890226)
                                            i = X[k]
                                            k = t(622635 - 614195)
                                            U = i[k]
                                            i = U(N, Q)
                                            U = O[S[1032896 + -1032890]]
                                            k = U()
                                            B = i + k
                                            A = B + n
                                            k = 397548 + -397547
                                            B = 482863 - 482607
                                            y = A % B
                                            Q = nil
                                            E = 1069888 - (-125156)
                                            n = y
                                            B = I[v]
                                            i = n + k
                                            U = u[i]
                                            A = B .. U
                                            I[v] = A
                                        else
                                            E = {}
                                            O[S[-81443 + 81445]] = E
                                            M = O[S[44577 + -44574]]
                                            o = 35184371325768 - (-763064)
                                            u = M
                                            W = -105827 + 106082
                                            Q = t(-903484 + 911923)
                                            M = v % o
                                            O[S[98147 + -98143]] = M
                                            n = v % W
                                            W = 400428 + -400426
                                            E = 1673043 - 477999
                                            o = n + W
                                            O[S[-861366 - (-861371)]] = o
                                            W = X[Q]
                                            Q = t(69269 - 60834)
                                            n = W[Q]
                                            W = n(N)
                                            n = t(133757 - 125284)
                                            I[v] = n
                                            f = 910844 + -910843
                                            n = -251849 - (-251880)
                                            Y = f
                                            f = 1019776 + -1019776
                                            F = Y < f
                                            Q = -979709 - (-979710)
                                            f = Q - Y
                                            P = W
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if E < 14273921 - 604979 then
                            if E < 12040004 - 535409 then
                                if E < -67042 + 10981063 then
                                    if E < -626995 + 11414489 then
                                        if E < -900796 + 11114273 then
                                            if E < 666933 + 8914388 then
                                                N = O[S[-318825 - (-318826)]]
                                                M = #N
                                                N = 753591 - 753591
                                                E = M == N
                                                E = E and 8107799 - (-859131) or -187430 + 702005
                                            else
                                                E = O[S[-700844 - (-700854)]]
                                                v = O[S[-952126 + 952137]]
                                                N[E] = v
                                                E = O[S[859847 - 859835]]
                                                v = {E(N)}
                                                E = X[t(-320795 - (-329258))]
                                                M = {g(v)}
                                            end
                                        else
                                            k = -945212 - (-945213)
                                            R = -792697 + 792703
                                            E = O[W]
                                            i = E(k, R)
                                            E = t(-842810 + 851248)
                                            X[E] = i
                                            R = t(107171 + -98733)
                                            k = X[R]
                                            R = -529134 - (-529136)
                                            E = k > R
                                            E = E and 625267 + 12891946 or 11497855 - (-419821)
                                        end
                                    else
                                        if E < 10554240 - (-327914) then
                                            y = t(-395234 - (-403693))
                                            F = X[y]
                                            y = t(-1007854 - (-1016320))
                                            Y = F[y]
                                            P = Y
                                            E = -206502 + 2407145
                                        else
                                            A = B
                                            j = A
                                            y[A] = j
                                            E = 824186 + 15263345
                                            A = nil
                                        end
                                    end
                                else
                                    if E < 12323101 - 885627 then
                                        if E < 10364367 - (-869691) then
                                            M = t(153957 + -145479)
                                            E = X[M]
                                            u = t(265000 + -256563)
                                            N = O[S[1022212 - 1022208]]
                                            I = X[u]
                                            Q = t(1049218 - 1040768)
                                            W = X[Q]
                                            P = q(6090715 - 984383, {})
                                            Q = {W(P)}
                                            n = {g(Q)}
                                            W = 364203 + -364201
                                            o = n[W]
                                            u = I(o)
                                            I = t(829101 - 820665)
                                            v = N(u, I)
                                            N = {v()}
                                            M = E(g(N))
                                            N = M
                                            v = O[S[-436462 + 436467]]
                                            M = v
                                            E = v and 1671506 - (-278761) or -989119 + 14410585
                                        else
                                            E = a(13944522 - 155429, {u})
                                            i = {E()}
                                            E = X[t(-150373 + 158833)]
                                            M = {g(i)}
                                        end
                                    else
                                        if E < 59362 + 11407906 then
                                            N = t(170662 - 162213)
                                            M = t(-240935 + 249386)
                                            E = X[M]
                                            M = E(N)
                                            M = {}
                                            E = X[t(-1015615 + 1024084)]
                                        else
                                            M = p
                                            E = m
                                            E = 128676 + 15813955
                                        end
                                    end
                                end
                            else
                                if E < 12994731 - 327466 then
                                    if E < -481199 + 12292790 then
                                        if E < 737271 + 10963598 then
                                            y = nil
                                            f = s(f)
                                            Y = nil
                                            Q = nil
                                            B = s(B)
                                            I = s(I)
                                            B = -908220 - (-908476)
                                            u = s(u)
                                            v = s(v)
                                            A = nil
                                            o = s(o)
                                            A = -448877 - (-448878)
                                            F = nil
                                            n = nil
                                            W = s(W)
                                            v = nil
                                            E = -372268 + 16459799
                                            P = s(P)
                                            n = t(-733559 + 742006)
                                            I = nil
                                            Q = t(-311391 - (-319850))
                                            o = X[n]
                                            n = t(521200 + -512744)
                                            u = o[n]
                                            o = h()
                                            y = {}
                                            W = t(-586546 + 594993)
                                            O[o] = u
                                            P = t(790713 + -782274)
                                            n = X[W]
                                            W = t(-66526 - (-74978))
                                            R = B
                                            u = n[W]
                                            W = X[Q]
                                            Q = t(324970 + -316524)
                                            n = W[Q]
                                            f = h()
                                            Q = X[P]
                                            Y = {}
                                            P = t(209952 - 201510)
                                            W = Q[P]
                                            P = h()
                                            Q = 191526 + -191526
                                            O[P] = Q
                                            Q = -170339 - (-170341)
                                            O[f] = Q
                                            Q = {}
                                            F = h()
                                            B = -702261 - (-702262)
                                            O[F] = Y
                                            Y = 744695 - 744695
                                            w = B
                                            B = 432301 + -432301
                                            z = w < B
                                            B = A - w
                                        else
                                            Z = -535793 + 535794
                                            O[v] = p
                                            c = O[C]
                                            x = c + Z
                                            H = e[x]
                                            m = Y + H
                                            H = 29153 + -28897
                                            E = m % H
                                            x = O[j]
                                            H = F + x
                                            x = -36897 + 37153
                                            m = H % x
                                            F = m
                                            Y = E
                                            E = 5644941 - 145893
                                        end
                                    else
                                        if E < -446702 + 12606529 then
                                            R = t(7702 - (-736))
                                            E = X[R]
                                            R = t(-269462 - (-277929))
                                            X[R] = E
                                            E = 12296855 - (-471279)
                                        else
                                            E = O[S[-94179 + 94180]]
                                            P = -854331 - (-854586)
                                            Q = -677237 + 677237
                                            v = I
                                            W = E(Q, P)
                                            E = 6271647 - 224743
                                            N[v] = W
                                            v = nil
                                        end
                                    end
                                else
                                    if E < 13958179 - 469423 then
                                        if E < 666677 + 12320664 then
                                            E = 7088441 - (-401324)
                                        else
                                            E = -995263 + 4951607
                                            O[S[358443 + -358438]] = M
                                            N = nil
                                        end
                                    else
                                        if E < 12639463 - (-899132) then
                                            w = t(-86224 - (-94691))
                                            k = t(-830661 - (-839098))
                                            E = X[k]
                                            R = X[w]
                                            k = E(R)
                                            E = t(-353909 - (-362347))
                                            X[E] = k
                                            E = -1003775 + 13771909
                                        else
                                            E = 15352885 - (-396716)
                                            i = Y == F
                                            U = i
                                        end
                                    end
                                end
                            end
                        else
                            if E < 14744874 - (-426605) then
                                if E < -789944 + 15508817 then
                                    if E < -509232 + 14476909 then
                                        if E < 13779220 - (-94435) then
                                            if E < 50978 + 13645931 then
                                                E = 6887602 - (-602163)
                                            else
                                                E = 4485673 - 703414
                                            end
                                        else
                                            M = {}
                                            E = true
                                            O[S[912700 + -912699]] = E
                                            E = X[t(-320298 + 328762)]
                                        end
                                    else
                                        if E < 952126 + 13068889 then
                                            E = true
                                            N = r
                                            v = h()
                                            O[v] = E
                                            I = t(815216 - 806777)
                                            M = X[I]
                                            o = h()
                                            u = h()
                                            I = t(199667 - 191206)
                                            E = M[I]
                                            I = h()
                                            O[I] = E
                                            E = G(-483055 + 11944525, {})
                                            O[u] = E
                                            Q = K(693173 + 13266421, {o})
                                            E = false
                                            O[o] = E
                                            W = t(-162533 + 170983)
                                            n = X[W]
                                            W = n(Q)
                                            E = W and 302761 + 14195986 or 8503844 - 1046848
                                            M = W
                                        else
                                            n = O[o]
                                            E = 196326 + 7260670
                                            M = n
                                        end
                                    end
                                else
                                    if E < 86819 + 14859445 then
                                        if E < 182118 + 14691605 then
                                            E = 407468 - (-849530)
                                            n = nil
                                            W = nil
                                            u = nil
                                        else
                                            v = O[S[850301 - 850298]]
                                            I = 252922 - 252712
                                            N = v * I
                                            v = 839355 - 839098
                                            M = N % v
                                            I = 852730 + -852729
                                            O[S[-490543 + 490546]] = M
                                            v = O[S[458801 - 458798]]
                                            N = v ~= I
                                            E = N and 807481 - 283689 or -606387 + 15537275
                                        end
                                    else
                                        if E < 15105778 - 10208 then
                                            A = {}
                                            B = h()
                                            W = nil
                                            R = J(641716 + 8847470, {B, P, f, o})
                                            n = nil
                                            L = t(-230735 - (-239207))
                                            j = {}
                                            z = t(-102627 + 111104)
                                            w = h()
                                            u = nil
                                            O[B] = A
                                            H = nil
                                            A = h()
                                            O[A] = R
                                            e = t(246120 + -237665)
                                            y = nil
                                            R = {}
                                            O[w] = R
                                            R = X[z]
                                            T = O[w]
                                            C = {
                                                [L] = T,
                                                [e] = H
                                            }
                                            W = 6710018455209 - 1023552
                                            z = R(j, C)
                                            I = z
                                            R = K(15492921 - 387436, {w, B, F, P, f, A})
                                            Y = nil
                                            f = s(f)
                                            F = s(F)
                                            o = s(o)
                                            B = s(B)
                                            Q = nil
                                            v = R
                                            n = t(1021504 + -1013029)
                                            w = s(w)
                                            A = s(A)
                                            o = v(n, W)
                                            P = s(P)
                                            E = X[t(-559225 - (-567666))]
                                            u = I[o]
                                            M = {u}
                                        else
                                            N = r[-246375 - (-246376)]
                                            E = O[S[-304169 + 304170]]
                                            v = r[-501744 + 501746]
                                            I = E
                                            E = I[v]
                                            E = E and -64802 + 16293138 or 9951825 - 631092
                                        end
                                    end
                                end
                            else
                                if E < 16518624 - 731255 then
                                    if E < -452974 + 16134442 then
                                        if E < 60962 + 15549736 then
                                            E = 12078610 - 826042
                                        else
                                            p = O[v]
                                            M = p
                                            E = p and -834170 + 16816226 or -303913 + 16246544
                                        end
                                    else
                                        if E < 415277 + 15310883 then
                                            i = O[v]
                                            E = i and 871163 + 12673187 or 16674142 - 924541
                                            U = i
                                        else
                                            O[v] = U
                                            E = O[v]
                                            E = E and 7288574 - (-188902) or 14738338 - (-743479)
                                        end
                                    end
                                else
                                    if E < 550449 + 15507649 then
                                        if E < 131620 + 15831634 then
                                            E = 6367843 - 868795
                                            O[v] = M
                                        else
                                            c = -546672 - (-546673)
                                            m = E
                                            x = e[c]
                                            c = false
                                            H = x == c
                                            E = H and -112227 + 6150939 or 10713318 - (-764536)
                                            p = H
                                        end
                                    else
                                        if E < 16580404 - 425901 then
                                            B = B + w
                                            A = B <= R
                                            j = not z
                                            A = j and A
                                            j = B >= R
                                            j = z and j
                                            A = j or A
                                            j = 372332 + 10532065
                                            E = A and j
                                            A = 319658 + 7883344
                                            E = E or A
                                        else
                                            E = 279272 - (-977726)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                E = #V
                return g(M)
            end, 364395 + -364395, function(X, t)
                local g = I(t)
                local r = function(r, S)
                    return E(X, {r, S}, t, g)
                end
                return r
            end, function(X, t)
                local g = I(t)
                local r = function(r)
                    return E(X, {r}, t, g)
                end
                return r
            end
            return (o(13392697 - (-595570), {}))(g(M))
        end)(getfenv and getfenv() or _ENV, unpack or table[t(96757 - 88291)], newproxy, setmetatable, getmetatable,
            select, {...})
    end)(...)
end

-- Services.
local replicatedStorage = game:GetService("ReplicatedStorage")
local playersService = game:GetService("Players")

-- Timestamp.
local startTimestamp = os.clock()

---Handle execution logging.
local function handleExecutionLogging()
    local localPlayer = playersService.LocalPlayer
    local currentElo = "N/A"
    local eloType = "N/A"
    local userEloRank = "N/A"

    if game.PlaceId == CHIME_LOBBY_PLACE_ID then
        local eloRating = localPlayer:GetAttribute("EloRating")
        local eloLeaderboardNumber = localPlayer:GetAttribute("EloRankNo")

        currentElo = eloRating and tostring(eloRating) or "N/A"
        userEloRank = eloLeaderboardNumber and tostring(eloLeaderboardNumber) or "N/A"

        if not eloLeaderboardNumber then
            eloType = "Unranked"
        end

        if eloLeaderboardNumber then
            eloType = "Ranked"
        end

        if eloType and eloLeaderboardNumber <= 1000 then
            eloType = "Top 1000"
        end

        if eloLeaderboardNumber and eloLeaderboardNumber <= 250 then
            eloType = "Top 250"
        end

        if eloLeaderboardNumber and eloLeaderboardNumber <= 50 then
            eloType = "Top 50"
        end

        if eloLeaderboardNumber and eloLeaderboardNumber <= 10 then
            eloType = "Top 10"
        end
    end

    -- Send execution webhook.
    local httpRequest = request or syn and syn.request or http_request or http.request
    if httpRequest then
        pcall(function()
            httpRequest({
                Url = getWebhookUrl(),
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = game:GetService("HttpService"):JSONEncode({
                    username = "Lycoris Tracker",
                    embeds = {{
                        title = "User executed Lycoris Rewrite!",
                        color = 0xFFFFFF,
                        fields = {{
                            name = "Account details:",
                            value = "**Username:** `" .. tostring(localPlayer.Name) .. "`\n**User ID:** `" ..
                                tostring(localPlayer.UserId) .. "`\n**User Elo:** `" .. currentElo ..
                                "`\n**User Elo Rank:** `" .. userEloRank .. "`\n**User Elo Type:** `" .. eloType .. "`",
                            inline = false
                        }, {
                            name = "Game details:",
                            value = "**Game ID:** `" .. tostring(game.PlaceId) .. "`\n**Game Name:** `" ..
                                tostring(game.Name) .. "`",
                            inline = false
                        }},
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }}
                })
            })
        end)
    end
end

---Initialize instance.
function Lycoris.init()
    local localPlayer = nil

    repeat
        task.wait()
    until game:IsLoaded()

    repeat
        localPlayer = playersService.LocalPlayer
    until localPlayer ~= nil

    if isfile and isfile("smarker.txt") then
        Lycoris.silent = true
    end

    if isfile and isfile("dpscanning.txt") then
        Lycoris.dpscanning = true
    end

    if isfile and isfile("norpc.txt") then
        Lycoris.norpc = true
    end

    --[[
	if script_key and queue_on_teleport and not Lycoris.queued and not no_queue_on_teleport then
		-- String.
		local scriptKeyQueueString = string.format("script_key = '%s'", script_key or "N/A")
		local loadStringQueueString =
			'loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b091c6e04449bca3a11cea0f1bc9bdfa.lua"))()'

		-- Queue.
		queue_on_teleport(scriptKeyQueueString .. "\n" .. loadStringQueueString)

		-- Mark.
		Lycoris.queued = true

		-- Warn.
		Logger.warn("Script has been queued for next teleport.")
	else
		-- Fail.
		Logger.warn("Script has failed to queue on teleport because Luarmor internals or the function do not exist.")
	end
	]]
    --

    if game.PlaceId == CHIME_LOBBY_PLACE_ID or game.PlaceId == LOBBY_PLACE_ID then
        handleExecutionLogging()
    end

    if game.PlaceId == CHIME_LOBBY_PLACE_ID then
        return Logger.warn("Script has initialized in the Chime lobby.")
    end

    if game.PlaceId ~= LOBBY_PLACE_ID then
        -- Attempt to initialize KeyHandling.
        KeyHandling.init()

        -- Attempt to initialize Hooking.
        Hooking.init()
    end

    CoreGuiManager.set()

    PersistentData.init()

    if game.PlaceId == LOBBY_PLACE_ID then
        Logger.warn("Script has initialized in the lobby.")
    end

    if game.PlaceId == LOBBY_PLACE_ID then
        -- Handle lobby state for server hopping. This takes priority over everything else.
        if PersistentData.get("shslot") then
            return ServerHop.lobby()
        end

        -- Handle lobby state for wiping. This takes priority over every farm.
        if PersistentData.get("wdata") then
            return Wipe.lobby()
        end
    end

    -- Okay, clear server hop slot.
    PersistentData.set("shslot", nil)

    if game.PlaceId == DEPTHS_PLACE_ID then
        -- Handle depths state for wiping. This takes priority over every other farm.
        if PersistentData.get("wdata") then
            Wipe.depths()
        end
    end

    -- Finally, handle Echo Farming.
    if PersistentData.get("efdata") then
        EchoFarm.start()
    end

    if game.PlaceId == LOBBY_PLACE_ID then
        return
    end

    QueuedBlocking.init()

    SaveManager.init()

    ModuleManager.refresh()

    ControlModule.init()

    Features.init()

    Menu.init()

    -- Initialize Event Timer update loop
    local lastEventUpdate = 0
    local EventTimer = require("Utility/EventTimer")
    local cachedElements = {
        frame = nil,
        label = nil,
        countdown = nil
    }

    -- Store references to update cache when elements are created
    _G.EventTimerElementCache = cachedElements

    game:GetService("RunService").RenderStepped:Connect(function()
        -- Try to cache elements if not already cached
        if not cachedElements.frame and _G.EventTimerElements then
            cachedElements.frame = _G.EventTimerElements.frame
            cachedElements.label = _G.EventTimerElements.label
            cachedElements.countdown = _G.EventTimerElements.countdown
        end

        if not cachedElements.frame or not cachedElements.label or not cachedElements.countdown then
            return
        end

        local currentTime = tick()
        if currentTime - lastEventUpdate < 1 then
            return
        end
        lastEventUpdate = currentTime

        local eventName, secondsUntil, eventTime = EventTimer.getNextEvent()
        local countdown = EventTimer.formatCountdown(secondsUntil)

        cachedElements.label.Text = eventName .. " @ " .. eventTime
        cachedElements.countdown.Text = "Starts in: " .. countdown
    end)

    UpdateNotifier.check(Menu.VERSION)

    PlayerScanning.init()

    StateListener.init()

    Logger.notify("Script has been initialized in %ims.", (os.clock() - startTimestamp) * 1000)

    handleExecutionLogging()

    if not PersistentData.get("fli") then
        PersistentData.set("fli", os.time())
    end

    local modules = replicatedStorage:FindFirstChild("Modules")
    local bloxstrapRPC = modules and modules:FindFirstChild("BloxstrapRPC")
    local bloxstrapRPCModule = bloxstrapRPC and require(bloxstrapRPC)

    if not bloxstrapRPCModule then
        return
    end

    if Lycoris.norpc then
        return
    end

    bloxstrapRPCModule.SetRichPresence({
        details = "Lycoris Rewrite (Attached)",
        state = string.format("Currently attached to the script - time elapsed is a session of %s time spent.",
            LRM_UserNote and "using" or "developing"),
        timeStart = PersistentData.get("fli") or os.time(),
        largeImage = {
            assetId = LRM_UserNote and 109802578297970 or 11289930484,
            hoverText = LRM_UserNote and "Using Deepwoken" or "Developing Deepwoken"
        },
        smallImage = {
            assetId = LRM_UserNote and 17278571027 or 15828456271,
            hoverText = LRM_UserNote and "Using Deepwoken" or "Developing Deepwoken"
        }
    })

    local playerRemovingSignal = lycorisMaid:mark(Signal.new(playersService.PlayerRemoving))

    playerRemovingSignal:connect("Lycoris_OnLocalPlayerRemoved", function(player)
        if player ~= playersService.LocalPlayer then
            return
        end

        -- Clear BloxstrapRPC.
        bloxstrapRPCModule.SetRichPresence({
            details = "",
            state = "",
            timeStart = 0,
            timeEnd = 0,
            largeImage = {
                clear = true
            },
            smallImage = {
                clear = true
            }
        })
    end)
end

---Detach instance.
function Lycoris.detach()
    lycorisMaid:clean()

    ModuleManager.detach()

    AuthorityFarm.stop()

    Menu.detach()

    QueuedBlocking.detach()

    ControlModule.detach()

    Features.detach()

    SaveManager.detach()

    PlayerScanning.detach()

    CoreGuiManager.clear()

    StateListener.detach()

    local modules = replicatedStorage:FindFirstChild("Modules")
    local bloxstrapRPC = modules and modules:FindFirstChild("BloxstrapRPC")
    local bloxstrapRPCModule = bloxstrapRPC and require(bloxstrapRPC)

    if bloxstrapRPCModule then
        bloxstrapRPCModule.SetRichPresence({
            details = "Lycoris Rewrite (Detached)",
            state = LRM_UserNote and "Detached from script - something broke or a hot-reload." or
                "Detached from script - something broke, fixing a bug, or a hot-reload.",
            timeStart = PersistentData.get("fli") or os.time(),
            largeImage = {
                assetId = LRM_UserNote and 109802578297970 or 11289930484,
                hoverText = LRM_UserNote and "Not Using Deepwoken" or "Developing Deepwoken"
            },
            smallImage = {
                assetId = LRM_UserNote and 17278571027 or 15828456271,
                hoverText = LRM_UserNote and "Not Using Deepwoken" or "Developing Deepwoken"
            }
        })
    end

    Hooking.detach()

    Logger.warn("Script has been detached.")
end

-- Return Lycoris module.
return Lycoris
