package j24w;

import j24w.Gui.GameView;
import j24w.FishyState;
import bootstrap.GameRunBase;
import ec.Entity;
import j24w.Building;
import j24w.Scheduler;
import stset.Stats;

class BuisinessGame extends GameRunBase {
    var state = new FishyState();
    var scheduler:Scheduler;
    var gui:GameView;

    public function new(e, ph) {
        super(e, ph);
        init();
    }

    function productionAction(r:Receipe, count:Int) {
        var available = 9999;
        var stats = state.stats;
        for (s in r.src) {
            var sa = Math.floor(stats.get(s.resId).value / s.count);
            if (sa < available)
                available = sa;
        }
        var produced = Math.min(count, available);
        for (s in r.src) {
            stats.get(s.resId).value -= produced * s.count;
        }
        stats.get(r.out).value += produced;
    }

    override function init() {
        super.init();
        scheduler = new Scheduler(state.time);
        gui = new GameView(getView());
        entity.addComponent(state);
        entity.addComponent(state.time);
        entity.addComponent(scheduler);
        gui.watch(entity);
        gui.entity.addComponent(state);
        gui.entity.addComponentByType(StatsSet, state.stats);
        addBuilding(0);
    }

    override function update(dt:Float) {
        state.time.t += dt;
        scheduler.update(dt);
    }

    function addBuilding(i:Int) {
        var b = createShellFarm();
        entity.addChild(b.entity);
        state.slots[i].value = Building(b);
    }

    function createShellFarm() {
        var r = {
            out: shell,
            src: []
        }
        var shellsTick = new TickUnit();
        shellsTick.onActivate = productionAction.bind(r, 2);
        var b = new Building(new Entity("shell-farm"));
        b.name = "farm";
        b.addTicker(shellsTick);
        return b;
    }
}

typedef Receipe = {
    out:ResId,
    src:Array<ResPile>
}

typedef ResPile = {
    resId:ResId,
    count:Int
}

enum abstract ResId(String) to String {
    var shell;
    var algae;
    var bivalvia;
    var buck;
}
