package j24w;

import j24w.Scheduler;
import ec.Component;

class Building extends Component {
    var tickers:Array<TickUnit> = [];
    public var name:String;
    @:once var scheduler:Scheduler;
    @:once var time:Time;

    override function init() {
        super.init();
        for (t in tickers)
            regTicker(t);
    }

    public function addTicker(t:TickUnit) {
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

    public function demolish() {}
}
