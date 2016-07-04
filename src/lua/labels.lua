LABELS = {
    list = {},      -- { [lbl]={}, [i]=lbl }
    code = nil,     -- see below
}

local function new (lbl)
    if lbl[2] then
        lbl.id = 'CEU_LABEL_'..lbl[1]
    else
        lbl.id = 'CEU_LABEL_'..lbl[1]..'_'..#LABELS.list
    end
    LABELS.list[lbl] = true
    lbl.n = #LABELS.list                   -- starts from 0
    LABELS.list[#LABELS.list+1] = lbl

    return lbl
end

F = {
    ROOT__PRE = function (me)
        me.lbl_in = new{'ROOT', true}
    end,

    Do = function (me)
        local _,_,set = unpack(me)
        if set then
            me.lbl_out = new{'Do'}
        end
    end,

    Par_Or__PRE  = 'Par__PRE',
    Par_And__PRE = 'Par__PRE',
    Par__PRE = function (me)
        me.lbls_in = {}
        for i, sub in ipairs(me) do
            if i < #me then
                -- the last executes directly (no label needed)
                me.lbls_in[i] = new{me.tag..'_sub_'..i}
            end
        end

        if me.tag ~= 'Par' then
            me.lbl_out = new{me.tag..'_out'}
        end

        if me.tag == 'Par_And' then
            me.lbl_tst = new{'Par_And_tst'}
        end
    end,
}

AST.visit(F)

LABELS.code = ''
for _, lbl in ipairs(LABELS.list) do
    LABELS.code = LABELS.code..lbl.id..',\n'
end
