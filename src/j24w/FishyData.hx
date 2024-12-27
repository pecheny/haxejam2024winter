package j24w;

import bootstrap.DefNode.DefLvlNode;
import bootstrap.DefNode.Leveled;



class BuildingsDef extends DefLvlNode<BuildingDef> { }
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
