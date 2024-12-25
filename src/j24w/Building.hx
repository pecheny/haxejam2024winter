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

    public var name:String;

    override function init() {
        super.init();
        for (t in tickers)
            regTicker(t);
    }

    public function addAction(a:Action) {
        var tk = new TickUnit();
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
        t.activationTime = time.getTime() + t.cd;
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
}
