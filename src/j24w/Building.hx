package j24w;

import ec.Component;
import j24w.FishyData;
import j24w.FishyState;
import update.Updatable;

class Building extends Component implements Updatable {
    public var name:String;
    public final chains:Array<ProductionChain> = [];

    @:once var time:Time;
    @:once var stats:AllStats;
    @:once var defs:BuildingsDef;
    var defId:String;
    var level:Int;

    public function update(dt) {
        for (ch in chains)
            ch.update();
    }

    public function demolish() {}

    public function serialize():BuildingState {
        return {
            defId: defId,
            level: level,
            timings: [for (tk in chains) tk.activationTime]
        }
    }

    public function loadState(state:BuildingState) {
        initBuilding(state.defId, state.level, state.timings);
        return this;
    }

    public function initBuilding(defId, level, ?timings:Array<Float>) {
        chains.resize(0);
        this.defId = defId;
        this.level = level;
        var def = defs.getLvl(defId, level);
        name = defId + " " + level;
        if (timings == null)
            for (a in def.actions)
                addAction(a, time.getTime() + a.cooldown);
        else
            for (i in 0...def.actions.length) {
                var a = def.actions[i];
                var timing = if (timings.length > i) timings[i] else time.getTime() + a.cooldown;
                addAction(a, timing);
            }
    }

    function addAction(r, at) {
        var chain = new ProductionChain(time, r, stats);
        chain.activationTime = at;
        chains.push(chain);
    }
}

enum abstract ChainState(Int) {
    var idle;
    var producing;
}

class ProductionChain {
    public var state(get, null):ChainState;
    public var receipe(default, null):Receipe;
    public var activationTime:Float;

    var stats:AllStats;
    var time:Time;

    public function new(time, receipe, stats) {
        this.time = time;
        this.receipe = receipe;
        this.stats = stats;
    }

    public function update() {
        switch state {
            case idle:
                if (validateState())
                    startProduction();
            case producing:
                if (validateState()) {
                    while (activationTime < time.getTime()) {
                        activationTime += receipe.cooldown;
                        action();
                    }
                } else
                    stopProduction();
        }
    }

    function stopProduction() {
        activationTime = 0;
    }

    function startProduction() {
        activationTime = time.getTime() + receipe.cooldown;
    }

    public function getProgress() {
        return switch state {
            case idle: 0;
            case producing:
                1 - (activationTime - time.getTime()) / receipe.cooldown;
        }
    }

    function action() {
        for (s in receipe.src) {
            stats.get(s.resId).value -= s.count;
        }
        stats.get(receipe.out.resId).value += receipe.out.count;
    }

    function validateState() {
        var available = true;
        for (s in receipe.src) {
            if (stats.get(s.resId).value < s.count) {
                available = false;
                break;
            }
        }
        return available;
    }

    function get_state():ChainState {
        return if (activationTime > 0) producing else idle;
    }
}

typedef BuildingState = {
    defId:String,
    level:Int,
    timings:Array<Float>
}
