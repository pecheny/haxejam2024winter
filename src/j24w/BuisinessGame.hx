package j24w;

import al.Builder;
import j24w.Gui;
import bootstrap.DefNode;
import j24w.FishyState;
import j24w.FishyData;
import bootstrap.GameRunBase;
import ec.Entity;
import j24w.Building;
import j24w.Scheduler;
import stset.Stats;

class BuisinessGame extends GameRunBase {
    var state = new FishyState();
    var scheduler:Scheduler;
    var gui:GameView;
    var buying:BuyingBilding;

    public function new(e, ph) {
        super(e, ph);
        init();
    }

    override function init() {
        super.init();
        var bdefs = new BuildingsDef("buildings", openfl.utils.Assets.getLibrary(""));
        // var bdefs = new BuildingsDef(new DefNode("buildings", openfl.utils.Assets.getLibrary("")).get);
        entity.addComponent(bdefs);
        scheduler = new Scheduler(state.time);
        gui = new GameView(getView());
        entity.addComponent(state);
        buying = entity.addComponent(new BuyingBilding());
        entity.addComponent(state.time);
        entity.addComponent(state.stats);
        entity.addComponent(scheduler);
        gui.watch(entity);
        var bb = gui.entity.addAliasByName(Entity.getComponentId(BuyBuilding), new BuyBuilding(Builder.widget()));
        bb.watch(entity);
        var bd = gui.entity.addAliasByName(Entity.getComponentId(BuildingDetails), new BuildingDetails(Builder.widget()));
        bd.watch(entity);

        // gui.entity.addComponent(state);
        gui.entity.addComponentByType(StatsSet, state.stats);
        buying.buy(0, "farm");
    }

    override function update(dt:Float) {
        state.time.t += dt;
        scheduler.update(dt);
    }


    // function createShellFarm() {
    //     // var r =
    //     var shellsTick = new TickUnit();
    //     shellsTick.onActivate = productionAction.bind(r, 2);
    //     var b = new Building(new Entity("shell-farm"));
    //     b.name = "farm";
    //     b.addTicker(shellsTick);
    //     return b;
    // }
}
