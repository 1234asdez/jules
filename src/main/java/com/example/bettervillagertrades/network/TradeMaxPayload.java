package com.example.bettervillagertrades.network;

import com.example.bettervillagertrades.BetterVillagerTrades;
import net.minecraft.network.RegistryByteBuf;
import net.minecraft.network.codec.PacketCodec;
import net.minecraft.network.codec.PacketCodecs;
import net.minecraft.network.packet.CustomPayload;
import net.minecraft.util.Identifier;

public record TradeMaxPayload(int tradeIndex) implements CustomPayload {
    public static final CustomPayload.Id<TradeMaxPayload> ID = new CustomPayload.Id<>(Identifier.of(BetterVillagerTrades.MOD_ID, "trade_max"));

    public static final PacketCodec<RegistryByteBuf, TradeMaxPayload> CODEC = PacketCodec.tuple(
            PacketCodecs.INTEGER, TradeMaxPayload::tradeIndex,
            TradeMaxPayload::new
    );

    @Override
    public Id<? extends CustomPayload> getId() {
        return ID;
    }
}
