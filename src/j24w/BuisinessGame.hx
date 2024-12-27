package j24w;

import update.Updatable;
import haxe.Json;
import al.Builder;
import j24w.Gui;
import bootstrap.DefNode;
import j24w.FishyState;
import j24w.FishyData;
import bootstrap.GameRunBase;
import ec.Entity;
import j24w.Building;
import stset.Stats;

class BuisinessGame extends GameRunBase {
    @:once var gui:GameView;
    var buying:BuyingBilding;
    @:once var state:FishyState;

    // public function new(e, ph) {
    //     super(e, ph);
    //     init();
    // }

    var buildings:Array<Updatable> = [];
    override function init() {
        super.init();
        var bdefs = new BuildingsDef("buildings", openfl.utils.Assets.getLibrary(""));
        // var bdefs = new BuildingsDef(new DefNode("buildings", openfl.utils.Assets.getLibrary("")).get);
        entity.addComponent(bdefs);
        buying = entity.addComponent(new BuyingBilding());
        gui.watch(entity);
        var bb = gui.entity.addAliasByName(Entity.getComponentId(BuyBuilding), new BuyBuilding(Builder.widget()));
        bb.watch(entity);
        var bd = gui.entity.addAliasByName(Entity.getComponentId(BuildingDetails), new BuildingDetails(Builder.widget()));
        bd.watch(entity);

        for (sl in state.slots){
            entity.addChild(sl.building.entity);
            buildings.push(sl.building);
        }

        gui.entity.addComponentByType(StatsSet, state.stats);
    }

    override function update(dt:Float) {
        state.time.t += dt;
        for (b in buildings)
            b.update(dt);
    }
}
