using System;
using System.Collections.Generic;
using System.Linq;
using Urchin.Server.Shared.DataContracts;

namespace Urchin.Server.Shared.TypeMappings
{
    public class DtoDeepCopy : AutoMapper.Profile
    {
        public override string ProfileName
        {
            get { return "DtoDeepCopy"; }
        }

        protected override void Configure()
        {
            CreateMap<ConfigNodeDto, ConfigNodeDto>()
                .ForMember(
                    dest => dest.Properties,
                    opt => opt.MapFrom(src => src.Properties.DeepClone()));

            CreateMap<ConfigPropertyDto, ConfigPropertyDto>()
                .ForMember(
                    dest => dest.PropertyValue,
                    opt => opt.MapFrom(src => src.PropertyValue.DeepClone()));

            CreateMap<EnvironmentDto, EnvironmentDto>()
                .ForMember(
                    dest => dest.Machines,
                    opt => opt.MapFrom(src => src.Machines.DeepClone()));

            CreateMap<RuleDto, RuleDto>()
                .ForMember(
                    dest => dest.Variables,
                    opt => opt.MapFrom(src => src.Variables.DeepClone()));

            CreateMap<RuleSetDto, RuleSetDto>()
                .ForMember(
                    dest => dest.Environments,
                    opt => opt.MapFrom(src => src.Environments.DeepClone()))
                .ForMember(
                    dest => dest.Rules,
                    opt => opt.MapFrom(src => src.Rules.DeepClone()));

            CreateMap<VariableDeclarationDto, VariableDeclarationDto>();
        }
    }

    public static class DeepCloneExtensions
    {
        public static List<T> DeepClone<T>(this List<T> original)
        {
            if (original == null) return null;
            lock(original) 
                return original.Select(AutoMapper.Mapper.Map<T, T>).ToList();
        }

        public static T DeepClone<T>(this T original)
        {
            return AutoMapper.Mapper.Map<T, T>(original);
        }
    }
}
