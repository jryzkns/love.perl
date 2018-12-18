-- computes the L2 norm of an N-dimensional vector
function norm(vec)
        local SS = 0
        for _,entry in pairs(vec) do
                SS = SS + entry^2
        end
        return math.sqrt(SS)
end

function dot(v1,v2)
        local dotprod = 0
        for i=1,table.getn(v1) do
                dotprod = dotprod + v1[i]*v2[i]
        end
        return dotprod
end

function subtract(v1,v2)
        local vec = getmat(1,table.getn(v1))
        for i=1,table.getn(v1) do
                vec[i] = v1[i] - v2[i]
        end
        return vec
end

function add(v1,v2)
        local vec = getmat(1,table.getn(v1))
        for i=1,table.getn(v1) do
                vec[i] = v1[i] + v2[i]
        end
        return vec
end

function mat_normalize(mat)
        local max, min = 0, 0
        local normalized = getmat(table.getn(mat),table.getn(mat[1]))

        -- grab (min,max) interval of matrix
        for i=1,table.getn(mat) do
                for j=1,table.getn(mat[1]) do
                        if mat[i][j] > max then max = mat[i][j] end
                        if mat[i][j] < min then min = mat[i][j] end
                end
        end

        local range = max - min

        for i=1,table.getn(mat) do
                for j=1,table.getn(mat[1]) do
                        normalized[i][j] = (mat[i][j] - min)/range
                end
        end

        return normalized

end

function getmat(r,c)
        
        local mat = {}
        
        for i=1,r do
                mat[i] = {}
                for j=1,c do
                        mat[i][j] = 0
                end
        end

        return mat
end

function normalize(v)
        local normalized_v = getmat(1,#v)
        local vnorm = norm(v)
        for i=1,#v do
                normalized_v[i] = v[i]/vnorm
        end
        return normalized_v
end