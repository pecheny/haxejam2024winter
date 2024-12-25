package j24w;

import bootstrap.DefNode.DefLvlNode;
import bootstrap.DefNode.Leveled;



class BuildingsDef extends DefLvlNode<BuildingDef> { }
typedef BuildingDef = {
    >Leveled,
    actions:Array<Receipe>,
    name:String
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
