package j24w;

import bootstrap.DefNode;


class BuildingsDef extends DefLvlNode<BuildingDef> { }
class ItemsDef extends DefNode<PerkUnit> { }

typedef BuildingDef = {
    >Leveled,
    >Merch,
    actions:Array<Receipe>,
    defId:String
}

typedef Merch = {
    price:Array<Int>
}

typedef Receipe = {
    out:ResPile,
    src:Array<ResPile>,
    cooldown:Float,
}

typedef ResPile = {
    resId:ResId,
    count:Float
}

enum abstract ResId(String) to String {
    var shell;
    var algae;
    var bivalvia;
    var buck;
}

typedef PerkUnit = {
    type:PerkType,
    target:String,
    value:Float
}
enum abstract PerkType(String) to String {
    var mp;
    var add;
}


