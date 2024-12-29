package j24w;

import fu.bootstrap.ButtonScale;
import j24w.FishyState.AllStats;
import j24w.FishyData.ItemsDef;
import j24w.Perks.ItemsProperty;
import fu.ui.InteractivePanelBuilder;
import fu.Signal.IntSignal;
import al.core.DataView;
import a2d.ChildrenPool.DataChildrenPool;
import j24w.FishyData.PerkUnit;
import Main.Lifecycle;
import al.layouts.PortionLayout;
import ec.Signal;
import fancy.domkit.Dkit;

using a2d.ProxyWidgetTransform;

class GreetView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <greet-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"We have a deal on starting your business on my land, but it's important to note that you will need to pay rent each month in order for the business to continue operating.
            I would like to remind you that the rent for your business will be increasing each month. It's important to keep up with these payments in order to continue operating on my property."} />
            <button(b().v(pfr, 0.1).b()) text={"I promise to pay my bills!    ..."} style={"right"} onClick={done} />

    </greet-view>

    function done() {
        onDone.dispatch();
        // l.showMenu();
    }
}


class GameOverView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();

    @:once var l:Lifecycle;

    static var SRC = <game-over-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}
            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"} text={"I'm sorry to hear that you didn't pay your rent on time. As a result, I have cancelled our deal and found someone else who is more reliable with their payments."} />
            <button(b().v(pfr, 0.1).b()) text={"ok"} style={"center"} onClick={done} />

    </game-over-view>

    function done() {
        // onDone.dispatch();
        l.showMenu();
    }
}

class CheckoutView extends BaseDkit {
    public var onDone:Signal<Void->Void> = new Signal();
    
    function text(toll:Int) {
        return
        '
        I must say that it\'s great to hear that you have paid your rent on time. 
        However, if you delay your payments next month, I will definitely cancel our deal and find someone else who is more reliable with their payments.
        Please pay $toll shells by the 1st of next month to continue your business.
        ';
    }

    static var SRC = <checkout-view vl={PortionLayout.instance}>
            ${fui.quad(__this__.ph, 0xBC0B0A0A)}

            <label(b().v(pfr, 0.3).b()) id="name"  style={"small-text"}  />
            <button(b().v(pfr, 0.1).b()) text={"ok"} style={"center"} onClick={done} />
    </checkout-view>

    function done() {
        onDone.dispatch();
    }
    
    public function setToll(toll:Int) {
        name.text=text(toll);
    }
}

class ItemCard extends BaseDkit implements DataView<String> {
    static var SRC = <item-card>
        ${fui.quad(__this__.ph.getInnerPh(), 0xBC0F7BFF)}
        <label(b().v(pfr, .3).b()) id="lbl"  color={ 0xecb7b7 } />
    </item-card>

    @:once var defs:ItemsDef;
    @:once var stats:AllStats;

    public function initData(descr:String) {
        var def = defs.get(descr);
        lbl.text = switch def.type {
            case add:
                'Make ${def.value}  ${def.target} more per action.';
            case mp:
                if (stats.keys.contains(def.target))
                    'Produce ${Std.int(def.value * 100)}% more ${def.target}s';
                else
                    '${def.target} ${Std.int(def.value * 100)}% faster.';
        }
        trace(descr);
    }
}

class BuyItem extends BaseDkit {
    static var SRC = <buy-item vl={PortionLayout.instance}>
        ${fui.quad(__this__.ph, 0xBC0E0E0E)}
        <label(b().v(pfr, .3).b()) id="lbl" style={"center"}  text={ "Choose booster:" }  />
        <base(b().v(pfr, 1).b()) id="cardsContainer" layouts={GuiStyles.L_HOR_CARDS}  />
</buy-item>

    public var onChoice(default, null) = new IntSignal();

    var input:DataChildrenPool<String, ItemCard>;
    @:once var items:ItemsProperty;

    override function init() {
        super.init();
        input = new InteractivePanelBuilder().withContainer(cardsContainer.c)
            .withWidget(() -> {
                var mc =
                new ItemCard(b().t(1).h(pfr, 1).v(sfr, 0.3).b());
                new ButtonScale(mc.entity);
                mc;
            })
            .withSignal(onChoice)
            .build();
    }

    public function initChoices(captions:Array<String>) {
        trace(input, captions);
        input.initData(captions);
    }
}
