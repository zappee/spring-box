/*
 *  Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
 *
 *  Since:  February 2025
 *  Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
 *
 *  Description:
 *     Hazelcast Java demo: Hazelcast configuration.
 */
package com.remal.springbox.demo.hazelcast.commons;

import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.config.EvictionConfig;
import com.hazelcast.config.EvictionPolicy;
import com.hazelcast.config.InMemoryFormat;
import com.hazelcast.config.NearCacheConfig;
import com.hazelcast.core.HazelcastInstance;

public class HazelcastConfiguration {

    public static final String NEAR_CACHE_CONFIG_NAME = "30-seconds-store";
    public static final String COUNTER_MAP_ID = "30-seconds-store";
    public static final int TTL_OF_NEAR_CACHE = 30;

    private static final String HZ_CLUSTER_NAME = "springbox-dev";
    private static final String HZ_CLUSTER_ADDRESS_1 = "localhost:13063";
    private static final String HZ_CLUSTER_ADDRESS_2 = "localhost:13073";

    /**
     * Hazelcast client configuration.
     *
     * <PRE>
     * Near-Cache-ID refers to the configuration of the Near-Cache that
     * exists on the client side. The Near-Cache-ID is used to configure
     * a Near Cache that is associated with a specific distributed map.
     * It is the key you use to identify the Near Cache configuration on
     * the client side.
     *
     * Map-ID refers to the distributed map that exists in the Hazelcast
     * cluster. The Map-ID is used to identify a distributed map within the
     * Hazelcast cluster. It is the key you use to access the distributed
     * data structure.
     * </PRE>
     *
     * @return Hazelcast client instance
     */
    public static HazelcastInstance getHazelcastInstance() {
        NearCacheConfig nearCacheConfigForCounterMap = new NearCacheConfig(NEAR_CACHE_CONFIG_NAME)
                .setInMemoryFormat(InMemoryFormat.BINARY)
                .setTimeToLiveSeconds(TTL_OF_NEAR_CACHE)
                .setMaxIdleSeconds(0)

                // Expiration means the eviction of expired records.
                // A record is expired:
                //    - if it is not touched (accessed/read) for max-idle-seconds
                //    - time-to-live-seconds passed since it is put to Near Cache
                .setEvictionConfig(new EvictionConfig()
                        .setEvictionPolicy(EvictionPolicy.LRU)
                        .setSize(1000));

        ClientConfig clientConfig = new ClientConfig();
        clientConfig.setClusterName(HZ_CLUSTER_NAME);
        clientConfig.getNetworkConfig().getAddresses().add(HZ_CLUSTER_ADDRESS_1);
        clientConfig.getNetworkConfig().getAddresses().add(HZ_CLUSTER_ADDRESS_2);
        clientConfig.addNearCacheConfig(nearCacheConfigForCounterMap);

        return HazelcastClient.newHazelcastClient(clientConfig);
    }
}
