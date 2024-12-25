package j24w;

import j24w.Scheduler;
import j24w.FishyState;
import j24w.FishyData;
import ec.Component;

class Building extends Component {
    var tickers:Array<TickUnit> = [];
    @:once var scheduler:Scheduler;
    @:once var time:Time;
    @:once var stats:AllStats;
    @:once var defs:BuildingsDef;

    public var name:String;

    override function init() {
        super.init();
        for (t in tickers)
            regTicker(t);
    }

    function addAction(a:Action, acTime) {
        var tk = new TickUnit();
        tk.activationTime = acTime;
        tk.onActivate.listen(productionAction.bind(a.receipe, a.count));
        tk.cd = a.cooldown;
        addTicker(tk);
    }

    function addTicker(t:TickUnit) {
        if (tickers.contains(t))
            throw "wrong";
        tickers.push(t);
        if (_inited)
            regTicker(t);
    }

    function regTicker(t:TickUnit) {
        scheduler.addTicker(t);
    }

    function productionAction(r:Receipe, count:Int) {
        var available = 9999;
        for (s in r.src) {
            // trace(stats.get(s.resId).value , s.count);
            var sa = Math.floor(stats.get(s.resId).value / s.count);
            if (sa < available)
                available = sa;
        }
        var produced = Math.min(count, available);
        trace(produced, count, available);
        for (s in r.src) {
            stats.get(s.resId).value -= produced * s.count;
        }
        stats.get(r.out).value += produced;
        // trace('$produced ${r.out} produced');
    }

    public function demolish() {}

    function unsubscribe() {
        for (tk in tickers) {
            scheduler.removeTicker(tk);
            tk.onActivate.asArray().resize(0);
        }
        tickers.resize(0);
    }

    var defId:String;
    var level:Int;

    public function serialize():BuildingState {
        return {
            defId: defId,
            level: level,
            timings: [for (tk in tickers) tk.activationTime]
        }
    }

    public function loadState(state:BuildingState) {
        initBuilding(state.defId, state.level, state.timings);
        return this;
    }

    public function initBuilding(defId, level, ?timings:Array<Float>) {
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
}

typedef BuildingState = {
    defId:String,
    level:Int,
    timings:Array<Float>
}
