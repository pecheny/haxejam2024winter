package j24w;

import j24w.Perks.ItemsProperty;
import ec.Entity;
import stset.Stats;
import haxe.ds.ReadOnlyArray;
import ec.Signal;
import j24w.Building;

class FishyState {
    // public var buildings:Array<Building>;
    public var slots(default, null):ReadOnlyArray<Slot>;
    public var stats(default, null):AllStats = new AllStats({});
    public var time:Time = new Time();
    public var month:Int = 0;
    public var items:ItemsProperty;
    public var greet:Bool = false;

    public function new(root:Entity) {
        slots = [for (i in 0...9) new Slot(i)];
        stats.initAll({shell: {value: 0, max: 100}});
        items = ItemsProperty.getOrCreate(root);
    }

    public function serialize() {
        return {
            time: time.t,
            stats: stats.getData(),
            slots: serializeSlots(),
            items: items.value,
            greet:greet,
            month: month
        }
    }

    public function load(state) {
        time.t = state.time;
        stats.initAll(state.stats);
        for (i in 0...slots.length) {
            var stslots:Array<SlotState> = state.slots;
            if (stslots.length > i) {
                var ss = stslots[i];
                slots[i].value = if (ss.isEmpty) Empty else Building(slots[i].building.loadState(ss));
            } else
                slots[i].value = Empty;
        }
        greet = state.greet;
        this.month = state.month ?? 0;
        if (state.items == null)
            items.value = [];
        else
            items.value = state.items;
    }

    function serializeSlots() {
        return [
            for (s in slots)
                switch s.value {
                    case Building(b):
                        b.serialize();
                    case _:
                        cast {isEmpty: true}
                }
        ];
    }
}

typedef State = {}

typedef SlotState = {
    > BuildingState,
    ?isEmpty:Bool
}

class Slot {
    public var value(default, set):SlotValue = Empty;
    public var onChange(default, null) = new Signal<Void->Void>();
    public final building:Building;
    public var i:Int;

    public function new(i) {
        this.i = i;
        building = new Building(new Entity("building-" + i));
    }

    function set_value(value:SlotValue):SlotValue {
        this.value = value;
        onChange.dispatch();
        return value;
    }
}

enum SlotValue {
    Building(b:Building);
    Empty;
}

class AllStats implements StatsSet {
    public var shell(default, null):CapGameStat<Int>;

    // public var alg_mp(default, null):TempIncGameStat<Int>;
    public var lamin(default, null):GameStat<Int>; // водрослт
    public var plank(default, null):GameStat<Int>; // водрослт
    public var buck(default, null):GameStat<Int>;
    public var toll(default, null):GameStat<Int>;

    public function initAll(data:{}) {
        for (k in keys) {
            var stat = get(k);
            if (Reflect.hasField(data, k)) {
                stat.loadData(Reflect.field(data, k));
            } else
                stat.value = 0;
        }
    }

    public function getData() {
        var stats = {};
        for (k in this.keys) {
            Reflect.setField(stats, k, this.get(k).getData());
        }
        return stats;
    }
}
