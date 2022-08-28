A = imread('C:\lenna.png')

[R,C] = size(A)
paddA = zeros(R+2, C+2)
for a = 2 : R+1
    for b = 2 : C+1
    paddA(a, b) = A(a-1, b-1)
    end
end
M = zeros(1,9)
out_A = zeros(R, C)

for c = 2 : R+1
    for d = 2 : C+1
        M(1) = paddA(c-1, d-1)
        M(2) = paddA(c-1, d)
        M(3) = paddA(c-1, d+1)
        M(4) = paddA(c, d-1)
        M(5) = paddA(c, d)
        M(6) = paddA(c, d+1)
        M(7) = paddA(c+1, d-1)
        M(8) = paddA(c+1, d)
        M(9) = paddA(c+1, d+1)
        for mn = 1 : 7
            for m = 1 : 8
                if(M(m+1) < M(m))
                    temp = M(m+1)
                    M(m+1) = M(m)
                    M(m) = temp
                end
            end
        end          
        out_A(c-1, d-1) = M(5)
    end
end