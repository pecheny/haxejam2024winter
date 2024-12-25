package j24w;

import bootstrap.DefNode.DefLvlNode;
import bootstrap.DefNode.Leveled;



class BuildingsDef extends DefLvlNode<BuildingDef> { }
typedef BuildingDef = {
    >Leveled,
    actions:Array<Action>,
    name:String
}

typedef Action = {
    cooldown:Float,
    receipe:Receipe,
    count:Int
}

typedef Receipe = {
    out:ResId,
    src:Array<ResPile>
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
