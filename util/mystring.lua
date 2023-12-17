



local Frac = {
}


function Frac:mult(f2)
    self.n = self.n * f2.n
    self.z = self.z * f2.z
end

function Frac:print()
    print(self.z .. "/" ..self.n)
end

function Frac.create(z, n)
    local self = {
        ['n'] = n,
        ['z'] = z
    }

    setmetatable(self, Frac)

    return Frac
end


local f = Frac.create(5, 2)

f:print()